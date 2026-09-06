from datetime import datetime, timezone
from typing import List, Optional, Tuple
from uuid import UUID
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, and_, desc, asc
from app.models.task import Task
from app.models.user import User
from app.schemas.task import TaskCreate, TaskUpdate
from app.services.reminder_service import ReminderService
from app.services.recurring_task_service import RecurringTaskService
from app.core.logging import logger


class TaskService:
    @staticmethod
    def create_task(db: Session, user: User, task_in: TaskCreate) -> Task:
        task = Task(
            user_id=user.id,
            title=task_in.title,
            description=task_in.description,
            due_at=task_in.due_at,
            priority=task_in.priority,
            category=task_in.category,
            status="pending"
        )
        db.add(task)
        db.commit()
        db.refresh(task)

        # Create requested reminders
        if task_in.reminders:
            ReminderService.create_reminders_for_task(db, task, task_in.reminders)

        # Create recurring configuration if requested
        if task_in.recurring:
            RecurringTaskService.create_recurring_config(db, task, task_in.recurring)

        db.refresh(task)
        return task

    @staticmethod
    def get_task_by_id(db: Session, user_id: UUID, task_id: UUID) -> Optional[Task]:
        return db.query(Task).options(
            joinedload(Task.reminders),
            joinedload(Task.recurring_config)
        ).filter(Task.id == task_id, Task.user_id == user_id).first()

    @staticmethod
    def get_tasks_paginated(
        db: Session,
        user_id: UUID,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        category: Optional[str] = None,
        search: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
        sort_by: str = "due_at",
        sort_order: str = "asc"
    ) -> Tuple[List[Task], int]:
        query = db.query(Task).options(
            joinedload(Task.reminders),
            joinedload(Task.recurring_config)
        ).filter(Task.user_id == user_id)

        # Auto update overdue status for pending tasks
        now_utc = datetime.now(timezone.utc)
        db.query(Task).filter(
            Task.user_id == user_id,
            Task.status == "pending",
            Task.due_at < now_utc
        ).update({"status": "overdue"})
        db.commit()

        if status:
            query = query.filter(Task.status == status)
        if priority:
            query = query.filter(Task.priority == priority)
        if category:
            query = query.filter(Task.category == category)
        if search:
            search_term = f"%{search}%"
            query = query.filter(or_(Task.title.ilike(search_term), Task.description.ilike(search_term)))

        total = query.count()

        sort_col = getattr(Task, sort_by, Task.due_at)
        if sort_order.lower() == "desc":
            query = query.order_by(desc(sort_col))
        else:
            query = query.order_by(asc(sort_col))

        offset = (page - 1) * page_size
        tasks = query.offset(offset).limit(page_size).all()
        return tasks, total

    @staticmethod
    def update_task(db: Session, task: Task, update_data: TaskUpdate) -> Task:
        for field, value in update_data.model_dump(exclude_unset=True).items():
            setattr(task, field, value)
        db.commit()
        db.refresh(task)
        return task

    @staticmethod
    def complete_task(db: Session, task: Task) -> Task:
        task.status = "completed"
        db.commit()
        # Cancel any remaining pending reminders
        ReminderService.cancel_task_reminders(db, task.id)
        db.refresh(task)

        # If recurring task, spawn next task occurrence
        if task.recurring_config and task.recurring_config.is_active:
            TaskService.spawn_next_recurring_instance(db, task)

        return task

    @staticmethod
    def cancel_task(db: Session, task: Task) -> Task:
        task.status = "cancelled"
        db.commit()
        ReminderService.cancel_task_reminders(db, task.id)
        db.refresh(task)
        return task

    @staticmethod
    def delete_task(db: Session, task: Task):
        db.delete(task)
        db.commit()

    @staticmethod
    def spawn_next_recurring_instance(db: Session, parent_task: Task) -> Optional[Task]:
        rec = parent_task.recurring_config
        if not rec or not rec.is_active:
            return None

        new_due_at = rec.next_run_at
        if rec.end_at and new_due_at > rec.end_at:
            rec.is_active = False
            db.commit()
            return None

        # Create new task instance
        new_task = Task(
            user_id=parent_task.user_id,
            title=parent_task.title,
            description=parent_task.description,
            due_at=new_due_at,
            priority=parent_task.priority,
            category=parent_task.category,
            status="pending"
        )
        db.add(new_task)
        db.commit()
        db.refresh(new_task)

        # Re-attach reminders for new instance based on original reminder types
        for orig_rem in parent_task.reminders:
            from app.schemas.reminder import ReminderCreate
            rem_in = ReminderCreate(reminder_type=orig_rem.reminder_type)
            ReminderService.add_single_reminder(db, new_task, rem_in)

        # Update next_run_at on recurring_config
        rec.next_run_at = RecurringTaskService.calculate_next_run(new_due_at, rec.repeat_type, rec.interval)
        db.commit()
        logger.info(f"Spawned recurring task instance: {new_task.id} due at {new_due_at}")
        return new_task
