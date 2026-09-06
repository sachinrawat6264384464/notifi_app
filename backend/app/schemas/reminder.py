from uuid import UUID
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, field_validator


class ReminderTypeEnum:
    CUSTOM = "custom"
    SEVEN_DAYS_BEFORE = "7_days_before"
    THREE_DAYS_BEFORE = "3_days_before"
    ONE_DAY_BEFORE = "1_day_before"
    TWO_HOURS_BEFORE = "2_hours_before"
    THIRTY_MINUTES_BEFORE = "30_minutes_before"
    EXACT_TIME = "exact_time"


class ReminderBase(BaseModel):
    reminder_type: str
    offset_minutes: Optional[int] = None  # Used if type is custom or calculation input
    custom_reminder_at: Optional[datetime] = None  # Used if absolute custom time specified


class ReminderCreate(ReminderBase):
    pass


class ReminderUpdate(BaseModel):
    reminder_type: Optional[str] = None
    reminder_at: Optional[datetime] = None
    status: Optional[str] = None


class ReminderResponse(BaseModel):
    id: UUID
    task_id: UUID
    reminder_at: datetime
    reminder_type: str
    status: str
    sent_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
