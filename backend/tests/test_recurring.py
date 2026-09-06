from datetime import datetime, timezone, timedelta
from app.services.recurring_task_service import RecurringTaskService


def test_recurring_next_run_calculation():
    start = datetime(2026, 9, 15, 10, 0, tzinfo=timezone.utc)

    # Daily
    next_daily = RecurringTaskService.calculate_next_run(start, "daily", 1)
    assert next_daily == datetime(2026, 9, 16, 10, 0, tzinfo=timezone.utc)

    # Weekly
    next_weekly = RecurringTaskService.calculate_next_run(start, "weekly", 1)
    assert next_weekly == datetime(2026, 9, 22, 10, 0, tzinfo=timezone.utc)

    # Yearly
    next_yearly = RecurringTaskService.calculate_next_run(start, "yearly", 1)
    assert next_yearly == datetime(2027, 9, 15, 10, 0, tzinfo=timezone.utc)


def test_device_registration(client):
    payload = {
        "fcm_token": "mock_fcm_token_xyz_123",
        "platform": "android",
        "device_name": "Pixel 8 Pro"
    }
    response = client.post("/api/v1/devices", json=payload)
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["fcm_token"] == payload["fcm_token"]
    assert data["platform"] == "android"
