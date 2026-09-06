from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, ConfigDict


class UserBase(BaseModel):
    name: str
    email: EmailStr
    timezone: str = "UTC"


class UserCreate(UserBase):
    firebase_uid: str


class UserUpdate(BaseModel):
    name: Optional[str] = None
    timezone: Optional[str] = None


class UserResponse(UserBase):
    id: UUID
    firebase_uid: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
