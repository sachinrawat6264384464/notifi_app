from uuid import UUID
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict


class NotificationBase(BaseModel):
    title: str
    body: str


class NotificationResponse(NotificationBase):
    id: UUID
    user_id: UUID
    task_id: Optional[UUID] = None
    reminder_id: Optional[UUID] = None
    status: str
    sent_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class NotificationPaginatedResponse(BaseModel):
    items: List[NotificationResponse]
    total: int
    page: int
    page_size: int
    unread_count: int
