from datetime import datetime, timedelta, timezone
from typing import Optional
from sqlalchemy.orm import Session
from app.models.recurring_task import RecurringTask
from app.models.task import Task
from app.schemas.recurring_task import RecurringTaskCreate, RecurringTaskUpdate
from app.core.logging import logger


class RecurringTaskService:
    @staticmethod
    def calculate_next_run(current_time: datetime, repeat_type: str, interval: int = 1) -> datetime:
        repeat_type = repeat_type.lower()
        if repeat_type == "daily":
            return current_time + timedelta(days=interval)
        elif repeat_type == "weekly":
            return current_time + timedelta(weeks=interval)
        elif repeat_type == "monthly":
            # Approximate 30 days or handle month increment
            month = current_time.month - 1 + interval
            year = current_time.year + month // 12
            month = month % 12 + 1
            day = min(current_time.day, 28)  # Safe day wrap
            return current_time.replace(year=year, month=month, day=day)
        elif repeat_type == "yearly":
            return current_time.replace(year=current_time.year + interval)
        elif repeat_type == "custom":
            return current_time + timedelta(days=interval)
        return current_time + timedelta(days=interval)

    @staticmethod
    def create_recurring_config(db: Session, task: Task, config_in: RecurringTaskCreate) -> RecurringTask:
        next_run = RecurringTaskService.calculate_next_run(
            task.due_at, config_in.repeat_type, config_in.interval
        )
        recurring = RecurringTask(
            task_id=task.id,
            repeat_type=config_in.repeat_type,
            interval=config_in.interval,
            start_at=config_in.start_at,
            end_at=config_in.end_at,
            next_run_at=next_run,
            is_active=True
        )
        db.add(recurring)
        db.commit()
        db.refresh(recurring)
        return recurring
