from datetime import datetime, timezone, timedelta


def test_create_and_get_task(client):
    due_at = (datetime.now(timezone.utc) + timedelta(days=2)).isoformat()
    payload = {
        "title": "Submit Assignment",
        "description": "Final project report",
        "due_at": due_at,
        "priority": "high",
        "category": "Academic",
        "reminders": [
            {"reminder_type": "1_day_before"},
            {"reminder_type": "2_hours_before"}
        ]
    }
    response = client.post("/api/v1/tasks", json=payload)
    assert response.status_code == 201
    res_data = response.json()
    assert res_data["success"] is True
    task = res_data["data"]
    assert task["title"] == "Submit Assignment"
    assert len(task["reminders"]) == 2

    # Get single task
    task_id = task["id"]
    get_res = client.get(f"/api/v1/tasks/{task_id}")
    assert get_res.status_code == 200
    assert get_res.json()["data"]["id"] == task_id


def test_complete_task(client):
    due_at = (datetime.now(timezone.utc) + timedelta(days=1)).isoformat()
    create_res = client.post("/api/v1/tasks", json={"title": "Test Task", "due_at": due_at})
    task_id = create_res.json()["data"]["id"]

    comp_res = client.post(f"/api/v1/tasks/{task_id}/complete")
    assert comp_res.status_code == 200
    assert comp_res.json()["data"]["status"] == "completed"
