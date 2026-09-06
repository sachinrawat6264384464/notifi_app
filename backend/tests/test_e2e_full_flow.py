from datetime import datetime, timezone, timedelta
from app.models.user import User
from app.models.task import Task
from app.models.reminder import Reminder
from app.models.recurring_task import RecurringTask
from app.models.device import Device
from app.models.notification import Notification
from app.services.user_service import UserService
from app.services.task_service import TaskService
from app.services.reminder_service import ReminderService
from app.services.recurring_task_service import RecurringTaskService
from app.services.notification_service import NotificationService
from app.workers.tasks import process_reminder_dispatch


def _normalize_dt(dt):
    if dt and dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


def test_e2e_user_provisioning_and_isolation(db, client):
    # Phase 4 & 5: Provision User A and User B
    user_a = UserService.get_or_create_user(
        db, firebase_uid="firebase_uid_user_a_101", email="user_a@example.com", name="User A", timezone="Asia/Kolkata"
    )
    user_b = UserService.get_or_create_user(
        db, firebase_uid="firebase_uid_user_b_202", email="user_b@example.com", name="User B", timezone="UTC"
    )

    assert user_a.id != user_b.id
    assert user_a.firebase_uid == "firebase_uid_user_a_101"
    assert user_b.firebase_uid == "firebase_uid_user_b_202"

    # User A creates a private task
    due_at = datetime.now(timezone.utc) + timedelta(days=5)
    task_a = Task(
        user_id=user_a.id,
        title="User A Secret Task",
        description="Private machine learning project",
        due_at=due_at,
        priority="high",
        status="pending"
    )
    db.add(task_a)
    db.commit()
    db.refresh(task_a)

    # Phase 6: Verify User B cannot access User A's task
    tasks_b, total_b = TaskService.get_tasks_paginated(db, user_id=user_b.id)
    assert total_b == 0
    assert len(tasks_b) == 0

    task_b_lookup = TaskService.get_task_by_id(db, user_id=user_b.id, task_id=task_a.id)
    assert task_b_lookup is None  # User B access rejected!


def test_e2e_multi_reminder_creation_and_timezone_conversion(db):
    user = UserService.get_or_create_user(
        db, firebase_uid="uid_reminder_user_303", email="reminder_user@example.com", name="Reminder Tester", timezone="Asia/Kolkata"
    )

    due_at = datetime(2026, 9, 15, 10, 0, tzinfo=timezone.utc)
    from app.schemas.task import TaskCreate
    from app.schemas.reminder import ReminderCreate

    task_in = TaskCreate(
        title="Submit Assignment",
        description="Final report",
        due_at=due_at,
        priority="urgent",
        category="Academic",
        reminders=[
            ReminderCreate(reminder_type="7_days_before"),
            ReminderCreate(reminder_type="3_days_before"),
            ReminderCreate(reminder_type="1_day_before"),
            ReminderCreate(reminder_type="2_hours_before"),
            ReminderCreate(reminder_type="30_minutes_before"),
            ReminderCreate(reminder_type="exact_time"),
            ReminderCreate(reminder_type="custom", offset_minutes=15)
        ]
    )

    task = TaskService.create_task(db, user, task_in)
    assert task.title == "Submit Assignment"
    assert len(task.reminders) == 7

    # Verify every reminder trigger time in PostgreSQL
    rem_map = {r.reminder_type: _normalize_dt(r.reminder_at) for r in task.reminders}
    assert rem_map["7_days_before"] == datetime(2026, 9, 8, 10, 0, tzinfo=timezone.utc)
    assert rem_map["3_days_before"] == datetime(2026, 9, 12, 10, 0, tzinfo=timezone.utc)
    assert rem_map["1_day_before"] == datetime(2026, 9, 14, 10, 0, tzinfo=timezone.utc)
    assert rem_map["2_hours_before"] == datetime(2026, 9, 15, 8, 0, tzinfo=timezone.utc)
    assert rem_map["30_minutes_before"] == datetime(2026, 9, 15, 9, 30, tzinfo=timezone.utc)
    assert rem_map["exact_time"] == due_at
    assert rem_map["custom"] == datetime(2026, 9, 15, 9, 45, tzinfo=timezone.utc)


def test_e2e_celery_idempotency_and_notification_dispatch(db):
    user = UserService.get_or_create_user(
        db, firebase_uid="uid_celery_user_404", email="celery_user@example.com", name="Celery Tester"
    )

    # Register mock FCM device
    from app.schemas.device import DeviceRegister
    dev_in = DeviceRegister(fcm_token="mock_token_device_device_a", platform="android", device_name="Pixel 8")
    from app.services.device_service import DeviceService
    DeviceService.register_or_update_device(db, user, dev_in)

    due_at = datetime.now(timezone.utc) + timedelta(minutes=5)
    task = Task(user_id=user.id, title="Test FCM Push Task", due_at=due_at, priority="medium", status="pending")
    db.add(task)
    db.commit()

    rem = Reminder(task_id=task.id, reminder_at=due_at - timedelta(minutes=1), reminder_type="exact_time", status="pending")
    db.add(rem)
    db.commit()
    db.refresh(rem)

    # Execute reminder dispatch
    process_reminder_dispatch(str(rem.id), db=db)

    db.refresh(rem)
    assert rem.status == "sent"
    assert rem.sent_at is not None

    # Idempotency check: Execute second time on same reminder
    process_reminder_dispatch(str(rem.id), db=db)
    db.refresh(rem)
    assert rem.status == "sent"  # Remained 'sent', no duplicate dispatch!


def test_e2e_recurring_task_instance_spawning(db):
    user = UserService.get_or_create_user(
        db, firebase_uid="uid_recurring_505", email="recurring@example.com", name="Recurring Tester"
    )

    due_at = datetime(2026, 9, 15, 10, 0, tzinfo=timezone.utc)
    from app.schemas.task import TaskCreate
    from app.schemas.recurring_task import RecurringTaskCreate
    from app.schemas.reminder import ReminderCreate

    task_in = TaskCreate(
        title="Weekly ML Study Group",
        due_at=due_at,
        priority="high",
        reminders=[ReminderCreate(reminder_type="1_day_before")],
        recurring=RecurringTaskCreate(repeat_type="weekly", interval=1, start_at=due_at)
    )

    task = TaskService.create_task(db, user, task_in)
    assert task.recurring_config is not None
    assert task.recurring_config.repeat_type == "weekly"

    # Complete task and verify next occurrence spawned
    completed_task = TaskService.complete_task(db, task)
    assert completed_task.status == "completed"

    # Query new pending instance
    tasks, count = TaskService.get_tasks_paginated(db, user_id=user.id, status="pending")
    assert count == 1
    new_instance = tasks[0]
    assert new_instance.title == "Weekly ML Study Group"
    assert _normalize_dt(new_instance.due_at) == datetime(2026, 9, 22, 10, 0, tzinfo=timezone.utc)
    assert len(new_instance.reminders) == 1
