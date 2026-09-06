from datetime import datetime, timezone, timedelta
from uuid import UUID
from sqlalchemy import and_, asc
from app.workers.celery_app import celery_app
from app.db.session import SessionLocal
from app.models.reminder import Reminder
from app.models.task import Task
from app.services.notification_service import NotificationService
from app.core.logging import logger


def process_reminder_dispatch(reminder_id_str: str, db=None):
    close_db = False
    if db is None:
        db = SessionLocal()
        close_db = True

    try:
        reminder_id = UUID(reminder_id_str)
        # Atomic lock check
        reminder = db.query(Reminder).filter(Reminder.id == reminder_id).with_for_update(skip_locked=True).first()
        if not reminder:
            logger.info(f"Reminder {reminder_id_str} not found or locked by another worker.")
            return

        if reminder.status != "pending":
            logger.info(f"Reminder {reminder_id_str} already processed (status: {reminder.status}). Skipping.")
            return

        # Mark as processing
        reminder.status = "processing"
        db.commit()

        task = reminder.task
        if not task or task.status in ["completed", "cancelled"]:
            reminder.status = "cancelled"
            db.commit()
            return

        # Prepare notification payload
        title = "⏰ Task Reminder"
        body = f"Reminder for '{task.title}' (Due at {task.due_at.strftime('%Y-%m-%d %H:%M UTC')})"

        notification = NotificationService.send_push_to_user(
            db,
            user_id=task.user_id,
            title=title,
            body=body,
            task_id=task.id,
            reminder_id=reminder.id
        )

        reminder.status = "sent" if notification.status == "sent" else "failed"
        reminder.sent_at = datetime.now(timezone.utc)
        db.commit()
        logger.info(f"Successfully processed reminder {reminder_id_str} with status {reminder.status}")
    finally:
        if close_db:
            db.close()


@celery_app.task(name="app.workers.tasks.send_reminder", bind=True, max_retries=3, default_retry_delay=60)
def send_reminder(self, reminder_id_str: str):
    """
    Idempotent reminder execution task.
    Locks row, checks status, dispatches FCM, updates status.
    """
    try:
        process_reminder_dispatch(reminder_id_str)
    except Exception as exc:
        logger.error(f"Error executing send_reminder task for {reminder_id_str}: {str(exc)}")
        raise self.retry(exc=exc)


@celery_app.task(name="app.workers.tasks.check_pending_reminders")
def check_pending_reminders():
    """
    Periodic beat task checking for due reminders in PostgreSQL.
    """
    db = SessionLocal()
    try:
        now_utc = datetime.now(timezone.utc)
        due_reminders = db.query(Reminder).filter(
            Reminder.status == "pending",
            Reminder.reminder_at <= now_utc
        ).order_by(asc(Reminder.reminder_at)).limit(100).all()

        logger.info(f"Check pending reminders found {len(due_reminders)} due reminders.")
        for rem in due_reminders:
            send_reminder.delay(str(rem.id))
    except Exception as e:
        logger.error(f"Error checking pending reminders: {str(e)}")
    finally:
        db.close()


@celery_app.task(name="app.workers.tasks.missed_reminder_recovery")
def missed_reminder_recovery():
    """
    Periodic recovery task for handling reminders missed during server downtime.
    """
    db = SessionLocal()
    try:
        now_utc = datetime.now(timezone.utc)
        cutoff_24h = now_utc - timedelta(hours=24)

        # Mark expired reminders older than 24 hours
        expired_count = db.query(Reminder).filter(
            Reminder.status == "pending",
            Reminder.reminder_at < cutoff_24h
        ).update({"status": "expired"})

        # Dispatch recent missed reminders
        missed_reminders = db.query(Reminder).filter(
            Reminder.status == "pending",
            Reminder.reminder_at >= cutoff_24h,
            Reminder.reminder_at <= now_utc
        ).all()

        logger.info(f"Missed reminder recovery: {expired_count} expired, {len(missed_reminders)} missed to resend.")
        for rem in missed_reminders:
            send_reminder.delay(str(rem.id))

        db.commit()
    except Exception as e:
        logger.error(f"Error executing missed reminder recovery: {str(e)}")
    finally:
        db.close()
