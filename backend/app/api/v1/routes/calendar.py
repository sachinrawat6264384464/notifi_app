from datetime import datetime, time, timezone, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_, asc

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.task import Task
from app.models.reminder import Reminder
from app.schemas.task import TaskResponse
from app.schemas.reminder import ReminderResponse
from app.schemas.response import APIResponse
from pydantic import BaseModel

router = APIRouter(tags=["Calendar & Dashboard"])


class DashboardSummary(BaseModel):
    today_count: int
    pending_count: int
    completed_count: int
    overdue_count: int
    high_priority_count: int
    next_reminder: Optional[ReminderResponse] = None
    today_tasks: List[TaskResponse] = []


@router.get("/dashboard", response_model=APIResponse[DashboardSummary])
def get_dashboard_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    now_utc = datetime.now(timezone.utc)
    today_start = datetime.combine(now_utc.date(), time.min).replace(tzinfo=timezone.utc)
    today_end = datetime.combine(now_utc.date(), time.max).replace(tzinfo=timezone.utc)

    # Queries
    user_tasks_q = db.query(Task).filter(Task.user_id == current_user.id)

    today_tasks = user_tasks_q.filter(and_(Task.due_at >= today_start, Task.due_at <= today_end)).all()
    pending_count = user_tasks_q.filter(Task.status == "pending").count()
    completed_count = user_tasks_q.filter(Task.status == "completed").count()
    overdue_count = user_tasks_q.filter(Task.status == "overdue").count()
    high_priority_count = user_tasks_q.filter(Task.priority.in_(["high", "urgent"]), Task.status != "completed").count()

    next_rem = db.query(Reminder).join(Reminder.task).filter(
        Reminder.task.has(user_id=current_user.id),
        Reminder.status == "pending",
        Reminder.reminder_at >= now_utc
    ).order_by(asc(Reminder.reminder_at)).first()

    return APIResponse(
        success=True,
        message="Dashboard summary retrieved successfully",
        data=DashboardSummary(
            today_count=len(today_tasks),
            pending_count=pending_count,
            completed_count=completed_count,
            overdue_count=overdue_count,
            high_priority_count=high_priority_count,
            next_reminder=ReminderResponse.model_validate(next_rem) if next_rem else None,
            today_tasks=[TaskResponse.model_validate(t) for t in today_tasks]
        )
    )


@router.get("/calendar", response_model=APIResponse[List[TaskResponse]])
def get_calendar_tasks(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    tasks = db.query(Task).filter(
        Task.user_id == current_user.id,
        Task.due_at >= start_date,
        Task.due_at <= end_date
    ).order_by(asc(Task.due_at)).all()

    return APIResponse(
        success=True,
        message="Calendar tasks retrieved successfully",
        data=[TaskResponse.model_validate(t) for t in tasks]
    )
