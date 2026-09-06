# API Documentation

Base Endpoint: `/api/v1`

Header Requirement: `Authorization: Bearer <firebase_id_token>`

## Summary Table of Endpoints

| Resource | Method | Path | Description |
|---|---|---|---|
| User | `GET` | `/users/me` | Fetch current user profile |
| User | `PATCH` | `/users/me` | Update current user name/timezone |
| Tasks | `POST` | `/tasks` | Create task with reminders & recurring config |
| Tasks | `GET` | `/tasks` | List tasks (supports filtering, pagination, search) |
| Tasks | `GET` | `/tasks/{id}` | Get task details |
| Tasks | `PATCH` | `/tasks/{id}` | Update task details |
| Tasks | `DELETE` | `/tasks/{id}` | Delete task |
| Tasks | `POST` | `/tasks/{id}/complete` | Mark task as completed |
| Tasks | `POST` | `/tasks/{id}/cancel` | Cancel task |
| Reminders | `POST` | `/tasks/{id}/reminders` | Add single reminder to task |
| Reminders | `GET` | `/tasks/{id}/reminders` | List task reminders |
| Reminders | `PATCH` | `/reminders/{id}` | Update reminder config |
| Reminders | `DELETE` | `/reminders/{id}` | Delete reminder |
| Recurring | `POST` | `/recurring-tasks` | Create recurring rule |
| Recurring | `GET` | `/recurring-tasks` | List user recurring rules |
| Notifications | `GET` | `/notifications` | List user notification history |
| Notifications | `POST` | `/notifications/{id}/read` | Mark notification as read |
| Notifications | `POST` | `/notifications/read-all` | Mark all notifications as read |
| Devices | `POST` | `/devices` | Register FCM device token |
| Devices | `DELETE` | `/devices/{id}` | Unregister device token |
| Dashboard | `GET` | `/dashboard` | Retrieve summary stats & today tasks |
| Calendar | `GET` | `/calendar` | Retrieve tasks between `start_date` and `end_date` |
