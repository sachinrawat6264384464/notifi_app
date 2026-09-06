def test_get_current_user_profile(client, test_user):
    response = client.get("/api/v1/users/me")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["email"] == test_user.email
    assert data["data"]["firebase_uid"] == test_user.firebase_uid


def test_update_user_profile(client, test_user):
    response = client.patch("/api/v1/users/me", json={"name": "Updated Name", "timezone": "Asia/Kolkata"})
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["name"] == "Updated Name"
    assert data["data"]["timezone"] == "Asia/Kolkata"
