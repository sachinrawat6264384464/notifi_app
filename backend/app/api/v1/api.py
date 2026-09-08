from fastapi import APIRouter
from app.api.v1.routes import (
    auth,
    users,
    tasks,
    reminders,
    recurring_tasks,
    notifications,
    devices,
    calendar
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(tasks.router)
api_router.include_router(reminders.router)
api_router.include_router(recurring_tasks.router)
api_router.include_router(notifications.router)
api_router.include_router(devices.router)
api_router.include_router(calendar.router)
