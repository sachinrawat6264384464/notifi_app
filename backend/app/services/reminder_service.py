from datetime import datetime, timedelta, timezone
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.reminder import Reminder
from app.models.task import Task
from app.schemas.reminder import ReminderCreate, ReminderUpdate, ReminderTypeEnum
from app.core.logging import logger


class ReminderService:
    @staticmethod
    def calculate_reminder_time(due_at: datetime, reminder_in: ReminderCreate) -> datetime:
        """
        Calculates UTC reminder_at timestamp based on task due_at and reminder config.
        """
        rtype = reminder_in.reminder_type.lower()
        if rtype == ReminderTypeEnum.SEVEN_DAYS_BEFORE:
            return due_at - timedelta(days=7)
        elif rtype == ReminderTypeEnum.THREE_DAYS_BEFORE:
            return due_at - timedelta(days=3)
        elif rtype == ReminderTypeEnum.ONE_DAY_BEFORE:
            return due_at - timedelta(days=1)
        elif rtype == ReminderTypeEnum.TWO_HOURS_BEFORE:
            return due_at - timedelta(hours=2)
        elif rtype == ReminderTypeEnum.THIRTY_MINUTES_BEFORE:
            return due_at - timedelta(minutes=30)
        elif rtype == ReminderTypeEnum.EXACT_TIME:
            return due_at
        elif rtype == ReminderTypeEnum.CUSTOM:
            if reminder_in.custom_reminder_at:
                return reminder_in.custom_reminder_at
            elif reminder_in.offset_minutes is not None:
                return due_at - timedelta(minutes=reminder_in.offset_minutes)
        # Default fallback
        return due_at

    @staticmethod
    def create_reminders_for_task(db: Session, task: Task, reminders_in: List[ReminderCreate]) -> List[Reminder]:
        created_reminders = []
        for r_in in reminders_in:
            rem_at = ReminderService.calculate_reminder_time(task.due_at, r_in)
            reminder = Reminder(
                task_id=task.id,
                reminder_at=rem_at,
                reminder_type=r_in.reminder_type,
                status="pending"
            )
            db.add(reminder)
            created_reminders.append(reminder)
        db.commit()
        for r in created_reminders:
            db.refresh(r)
        return created_reminders

    @staticmethod
    def add_single_reminder(db: Session, task: Task, r_in: ReminderCreate) -> Reminder:
        rem_at = ReminderService.calculate_reminder_time(task.due_at, r_in)
        reminder = Reminder(
            task_id=task.id,
            reminder_at=rem_at,
            reminder_type=r_in.reminder_type,
            status="pending"
        )
        db.add(reminder)
        db.commit()
        db.refresh(reminder)
        return reminder

    @staticmethod
    def update_reminder(db: Session, reminder: Reminder, update_data: ReminderUpdate) -> Reminder:
        if update_data.reminder_type is not None:
            reminder.reminder_type = update_data.reminder_type
        if update_data.reminder_at is not None:
            reminder.reminder_at = update_data.reminder_at
        if update_data.status is not None:
            reminder.status = update_data.status
        db.commit()
        db.refresh(reminder)
        return reminder

    @staticmethod
    def cancel_task_reminders(db: Session, task_id: UUID):
        db.query(Reminder).filter(
            Reminder.task_id == task_id,
            Reminder.status == "pending"
        ).update({"status": "cancelled"})
        db.commit()
