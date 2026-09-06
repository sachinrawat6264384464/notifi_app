from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.recurring_task import RecurringTask
from app.schemas.recurring_task import RecurringTaskCreate, RecurringTaskUpdate, RecurringTaskResponse
from app.schemas.response import APIResponse
from app.services.task_service import TaskService
from app.services.recurring_task_service import RecurringTaskService

router = APIRouter(prefix="/recurring-tasks", tags=["Recurring Tasks"])


@router.post("", response_model=APIResponse[RecurringTaskResponse], status_code=status.HTTP_201_CREATED)
def create_recurring_config(
    task_id: UUID,
    config_in: RecurringTaskCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = TaskService.get_task_by_id(db, current_user.id, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found or access denied"
        )
    rec = RecurringTaskService.create_recurring_config(db, task, config_in)
    return APIResponse(
        success=True,
        message="Recurring task rule created successfully",
        data=RecurringTaskResponse.model_validate(rec)
    )


@router.get("", response_model=APIResponse[List[RecurringTaskResponse]])
def get_user_recurring_rules(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rules = db.query(RecurringTask).join(RecurringTask.task).filter(
        RecurringTask.task.has(user_id=current_user.id)
    ).all()
    return APIResponse(
        success=True,
        message="Recurring rules retrieved successfully",
        data=[RecurringTaskResponse.model_validate(r) for r in rules]
    )


@router.get("/{id}", response_model=APIResponse[RecurringTaskResponse])
def get_recurring_rule(
    id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rule = db.query(RecurringTask).join(RecurringTask.task).filter(
        RecurringTask.id == id,
        RecurringTask.task.has(user_id=current_user.id)
    ).first()
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring rule not found or access denied"
        )
    return APIResponse(
        success=True,
        message="Recurring rule retrieved successfully",
        data=RecurringTaskResponse.model_validate(rule)
    )


@router.patch("/{id}", response_model=APIResponse[RecurringTaskResponse])
def update_recurring_rule(
    id: UUID,
    update_data: RecurringTaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rule = db.query(RecurringTask).join(RecurringTask.task).filter(
        RecurringTask.id == id,
        RecurringTask.task.has(user_id=current_user.id)
    ).first()
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring rule not found or access denied"
        )
    for field, val in update_data.model_dump(exclude_unset=True).items():
        setattr(rule, field, val)
    db.commit()
    db.refresh(rule)
    return APIResponse(
        success=True,
        message="Recurring rule updated successfully",
        data=RecurringTaskResponse.model_validate(rule)
    )


@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_recurring_rule(
    id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rule = db.query(RecurringTask).join(RecurringTask.task).filter(
        RecurringTask.id == id,
        RecurringTask.task.has(user_id=current_user.id)
    ).first()
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring rule not found or access denied"
        )
    db.delete(rule)
    db.commit()
    return APIResponse(
        success=True,
        message="Recurring rule deleted successfully"
    )
