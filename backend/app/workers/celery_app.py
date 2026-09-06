from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "smart_scheduler_workers",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["app.workers.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,
    beat_schedule={
        "check-pending-reminders-every-30s": {
            "task": "app.workers.tasks.check_pending_reminders",
            "schedule": 30.0,
        },
        "recover-missed-reminders-hourly": {
            "task": "app.workers.tasks.missed_reminder_recovery",
            "schedule": 3600.0,
        },
    }
)
