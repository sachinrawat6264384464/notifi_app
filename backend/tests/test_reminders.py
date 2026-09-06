from datetime import datetime, timezone, timedelta
from app.services.reminder_service import ReminderService
from app.schemas.reminder import ReminderCreate, ReminderTypeEnum


def test_reminder_calculation_presets():
    due_at = datetime(2026, 9, 15, 10, 0, tzinfo=timezone.utc)

    # 7 days before
    r1 = ReminderCreate(reminder_type=ReminderTypeEnum.SEVEN_DAYS_BEFORE)
    assert ReminderService.calculate_reminder_time(due_at, r1) == datetime(2026, 9, 8, 10, 0, tzinfo=timezone.utc)

    # 3 days before
    r2 = ReminderCreate(reminder_type=ReminderTypeEnum.THREE_DAYS_BEFORE)
    assert ReminderService.calculate_reminder_time(due_at, r2) == datetime(2026, 9, 12, 10, 0, tzinfo=timezone.utc)

    # 1 day before
    r3 = ReminderCreate(reminder_type=ReminderTypeEnum.ONE_DAY_BEFORE)
    assert ReminderService.calculate_reminder_time(due_at, r3) == datetime(2026, 9, 14, 10, 0, tzinfo=timezone.utc)

    # 2 hours before
    r4 = ReminderCreate(reminder_type=ReminderTypeEnum.TWO_HOURS_BEFORE)
    assert ReminderService.calculate_reminder_time(due_at, r4) == datetime(2026, 9, 15, 8, 0, tzinfo=timezone.utc)

    # 30 minutes before
    r5 = ReminderCreate(reminder_type=ReminderTypeEnum.THIRTY_MINUTES_BEFORE)
    assert ReminderService.calculate_reminder_time(due_at, r5) == datetime(2026, 9, 15, 9, 30, tzinfo=timezone.utc)

    # Exact time
    r6 = ReminderCreate(reminder_type=ReminderTypeEnum.EXACT_TIME)
    assert ReminderService.calculate_reminder_time(due_at, r6) == due_at

    # Custom offset (15 minutes)
    r7 = ReminderCreate(reminder_type=ReminderTypeEnum.CUSTOM, offset_minutes=15)
    assert ReminderService.calculate_reminder_time(due_at, r7) == datetime(2026, 9, 15, 9, 45, tzinfo=timezone.utc)
