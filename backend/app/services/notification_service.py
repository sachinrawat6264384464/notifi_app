from datetime import datetime, timezone
from typing import List, Optional, Tuple
from uuid import UUID
from sqlalchemy.orm import Session
from sqlalchemy import desc
import firebase_admin
from firebase_admin import messaging

from app.models.notification import Notification
from app.models.device import Device
from app.models.user import User
from app.services.device_service import DeviceService
from app.core.logging import logger
from app.core.config import settings


class NotificationService:
    @staticmethod
    def send_push_to_user(
        db: Session,
        user_id: UUID,
        title: str,
        body: str,
        task_id: Optional[UUID] = None,
        reminder_id: Optional[UUID] = None
    ) -> Notification:
        # Create notification history record
        now_utc = datetime.now(timezone.utc)
        notification = Notification(
            user_id=user_id,
            task_id=task_id,
            reminder_id=reminder_id,
            title=title,
            body=body,
            status="pending"
        )
        db.add(notification)
        db.commit()
        db.refresh(notification)

        devices = DeviceService.get_user_devices(db, user_id)
        if not devices:
            logger.warning(f"No registered devices for user {user_id}. Marking notification as sent in history.")
            notification.status = "sent"
            notification.sent_at = now_utc
            db.commit()
            return notification

        success_count = 0
        for device in devices:
            if settings.APP_ENV in ["development", "testing"] and device.fcm_token.startswith("mock_token_"):
                logger.info(f"[Mock Push] Sent to device {device.fcm_token}: {title} - {body}")
                success_count += 1
                continue

            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=body,
                    ),
                    data={
                        "task_id": str(task_id) if task_id else "",
                        "reminder_id": str(reminder_id) if reminder_id else "",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK"
                    },
                    token=device.fcm_token,
                )
                messaging.send(message)
                success_count += 1
            except messaging.UnregisteredError:
                logger.warning(f"FCM token unregistered/invalid. Deleting: {device.fcm_token[:10]}...")
                DeviceService.remove_invalid_token(db, device.fcm_token)
            except Exception as e:
                logger.error(f"FCM send error to token {device.fcm_token[:10]}: {str(e)}")

        notification.status = "sent" if success_count > 0 else "failed"
        notification.sent_at = now_utc
        db.commit()
        db.refresh(notification)
        return notification

    @staticmethod
    def get_user_notifications(
        db: Session,
        user_id: UUID,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Notification], int, int]:
        query = db.query(Notification).filter(Notification.user_id == user_id)
        total = query.count()
        unread_count = query.filter(Notification.status != "read").count()

        offset = (page - 1) * page_size
        items = query.order_by(desc(Notification.created_at)).offset(offset).limit(page_size).all()
        return items, total, unread_count

    @staticmethod
    def mark_as_read(db: Session, user_id: UUID, notification_id: UUID) -> Optional[Notification]:
        notif = db.query(Notification).filter(
            Notification.id == notification_id,
            Notification.user_id == user_id
        ).first()
        if notif:
            notif.status = "read"
            db.commit()
            db.refresh(notif)
        return notif

    @staticmethod
    def mark_all_as_read(db: Session, user_id: UUID) -> int:
        count = db.query(Notification).filter(
            Notification.user_id == user_id,
            Notification.status != "read"
        ).update({"status": "read"})
        db.commit()
        return count
