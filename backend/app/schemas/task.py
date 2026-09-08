from uuid import UUID
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from app.schemas.reminder import ReminderCreate, ReminderResponse
from app.schemas.recurring_task import RecurringTaskCreate, RecurringTaskResponse


class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_at: datetime
    priority: str = "medium"  # low, medium, high, urgent
    category: Optional[str] = None
    subtasks: Optional[List[dict]] = []


class TaskCreate(TaskBase):
    reminders: Optional[List[ReminderCreate]] = None
    recurring: Optional[RecurringTaskCreate] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_at: Optional[datetime] = None
    priority: Optional[str] = None
    category: Optional[str] = None
    status: Optional[str] = None
    subtasks: Optional[List[dict]] = None


class TaskResponse(TaskBase):
    id: UUID
    user_id: UUID
    status: str
    subtasks: List[dict] = []
    created_at: datetime
    updated_at: datetime
    reminders: List[ReminderResponse] = []
    recurring_config: Optional[RecurringTaskResponse] = None

    model_config = ConfigDict(from_attributes=True)


class TaskPaginatedResponse(BaseModel):
    items: List[TaskResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
