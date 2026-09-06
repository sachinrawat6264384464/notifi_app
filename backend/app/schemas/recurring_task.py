from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class RecurringTaskBase(BaseModel):
    repeat_type: str  # daily, weekly, monthly, yearly, custom
    interval: int = 1
    start_at: datetime
    end_at: Optional[datetime] = None


class RecurringTaskCreate(RecurringTaskBase):
    pass


class RecurringTaskUpdate(BaseModel):
    repeat_type: Optional[str] = None
    interval: Optional[int] = None
    end_at: Optional[datetime] = None
    is_active: Optional[bool] = None


class RecurringTaskResponse(RecurringTaskBase):
    id: UUID
    task_id: UUID
    next_run_at: datetime
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
