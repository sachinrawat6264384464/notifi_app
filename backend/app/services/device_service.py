from datetime import datetime, timezone
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.device import Device
from app.models.user import User
from app.schemas.device import DeviceRegister, DeviceUpdate
from app.core.logging import logger


class DeviceService:
    @staticmethod
    def register_or_update_device(db: Session, user: User, device_in: DeviceRegister) -> Device:
        # Check if FCM token already registered (even if under another user or device)
        device = db.query(Device).filter(Device.fcm_token == device_in.fcm_token).first()
        now_utc = datetime.now(timezone.utc)

        if device:
            device.user_id = user.id
            device.platform = device_in.platform
            if device_in.device_name:
                device.device_name = device_in.device_name
            device.last_active_at = now_utc
            device.updated_at = now_utc
        else:
            device = Device(
                user_id=user.id,
                fcm_token=device_in.fcm_token,
                platform=device_in.platform,
                device_name=device_in.device_name or "Mobile Device",
                last_active_at=now_utc
            )
            db.add(device)

        db.commit()
        db.refresh(device)
        logger.info(f"Registered/updated FCM device: {device.id} for user {user.id}")
        return device

    @staticmethod
    def get_user_devices(db: Session, user_id: UUID) -> List[Device]:
        return db.query(Device).filter(Device.user_id == user_id).all()

    @staticmethod
    def delete_device(db: Session, user_id: UUID, device_id: UUID):
        device = db.query(Device).filter(Device.id == device_id, Device.user_id == user_id).first()
        if device:
            db.delete(device)
            db.commit()

    @staticmethod
    def remove_invalid_token(db: Session, fcm_token: str):
        db.query(Device).filter(Device.fcm_token == fcm_token).delete()
        db.commit()
        logger.info(f"Removed invalid FCM token from database: {fcm_token[:10]}...")
