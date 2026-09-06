from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.device import DeviceRegister, DeviceUpdate, DeviceResponse
from app.schemas.response import APIResponse
from app.services.device_service import DeviceService

router = APIRouter(prefix="/devices", tags=["Devices"])


@router.post("", response_model=APIResponse[DeviceResponse], status_code=status.HTTP_201_CREATED)
def register_device(
    device_in: DeviceRegister,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    device = DeviceService.register_or_update_device(db, current_user, device_in)
    return APIResponse(
        success=True,
        message="Device FCM token registered successfully",
        data=DeviceResponse.model_validate(device)
    )


@router.get("", response_model=APIResponse[List[DeviceResponse]])
def get_user_devices(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    devices = DeviceService.get_user_devices(db, current_user.id)
    return APIResponse(
        success=True,
        message="User devices retrieved successfully",
        data=[DeviceResponse.model_validate(d) for d in devices]
    )


@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_device(
    id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    DeviceService.delete_device(db, current_user.id, id)
    return APIResponse(
        success=True,
        message="Device unregistered successfully"
    )
