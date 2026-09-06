from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.reminder import Reminder
from app.schemas.reminder import ReminderCreate, ReminderUpdate, ReminderResponse
from app.schemas.response import APIResponse
from app.services.task_service import TaskService
from app.services.reminder_service import ReminderService

router = APIRouter(tags=["Reminders"])


@router.post("/tasks/{task_id}/reminders", response_model=APIResponse[ReminderResponse], status_code=status.HTTP_201_CREATED)
def create_reminder_for_task(
    task_id: UUID,
    reminder_in: ReminderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = TaskService.get_task_by_id(db, current_user.id, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found or access denied"
        )
    reminder = ReminderService.add_single_reminder(db, task, reminder_in)
    return APIResponse(
        success=True,
        message="Reminder added successfully",
        data=ReminderResponse.model_validate(reminder)
    )


@router.get("/tasks/{task_id}/reminders", response_model=APIResponse[List[ReminderResponse]])
def get_task_reminders(
    task_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = TaskService.get_task_by_id(db, current_user.id, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found or access denied"
        )
    return APIResponse(
        success=True,
        message="Reminders retrieved successfully",
        data=[ReminderResponse.model_validate(r) for r in task.reminders]
    )


@router.patch("/reminders/{reminder_id}", response_model=APIResponse[ReminderResponse])
def update_reminder(
    reminder_id: UUID,
    update_data: ReminderUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reminder = db.query(Reminder).join(Reminder.task).filter(
        Reminder.id == reminder_id,
        Reminder.task.has(user_id=current_user.id)
    ).first()
    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reminder not found or access denied"
        )
    updated_rem = ReminderService.update_reminder(db, reminder, update_data)
    return APIResponse(
        success=True,
        message="Reminder updated successfully",
        data=ReminderResponse.model_validate(updated_rem)
    )


@router.delete("/reminders/{reminder_id}", status_code=status.HTTP_200_OK)
def delete_reminder(
    reminder_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reminder = db.query(Reminder).join(Reminder.task).filter(
        Reminder.id == reminder_id,
        Reminder.task.has(user_id=current_user.id)
    ).first()
    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reminder not found or access denied"
        )
    db.delete(reminder)
    db.commit()
    return APIResponse(
        success=True,
        message="Reminder deleted successfully"
    )
