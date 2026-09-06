from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class DeviceRegister(BaseModel):
    fcm_token: str
    platform: str  # android, ios
    device_name: Optional[str] = None


class DeviceUpdate(BaseModel):
    fcm_token: Optional[str] = None
    device_name: Optional[str] = None


class DeviceResponse(BaseModel):
    id: UUID
    user_id: UUID
    fcm_token: str
    platform: str
    device_name: Optional[str] = None
    last_active_at: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
