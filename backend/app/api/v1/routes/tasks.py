import math
from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse, TaskPaginatedResponse
from app.schemas.response import APIResponse
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.post("", response_model=APIResponse[TaskResponse], status_code=status.HTTP_201_CREATED)
def create_task(
    task_in: TaskCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = TaskService.create_task(db, current_user, task_in)
    return APIResponse(
        success=True,
        message="Task created successfully",
        data=TaskResponse.model_validate(task)
    )


@router.get("", response_model=APIResponse[TaskPaginatedResponse])
def get_tasks(
    status_filter: Optional[str] = Query(None, alias="status"),
    priority_filter: Optional[str] = Query(None, alias="priority"),
    category_filter: Optional[str] = Query(None, alias="category"),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: str = Query("due_at"),
    sort_order: str = Query("asc"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    tasks, total = TaskService.get_tasks_paginated(
        db,
        user_id=current_user.id,
        status=status_filter,
        priority=priority_filter,
        category=category_filter,
        search=search,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_order=sort_order
    )
    total_pages = math.ceil(total / page_size) if total > 0 else 1
    return APIResponse(
        success=True,
        message="Tasks retrieved successfully",
        data=TaskPaginatedResponse(
            items=[TaskResponse.model_validate(t) for t in tasks],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )
    )


@router.get("/{task_id}", response_model=APIResponse[TaskResponse])
def get_task(
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
        message="Task retrieved successfully",
        data=TaskResponse.model_validate(task)
    )


@router.patch("/{task_id}", response_model=APIResponse[TaskResponse])
def update_task(
    task_id: UUID,
    update_data: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = TaskService.get_task_by_id(db, current_user.id, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found or access denied"
        )
    updated_task = TaskService.update_task(db, task, update_data)
    return APIResponse(
        success=True,
        message="Task updated successfully",
        data=TaskResponse.model_validate(updated_task)
    )


@router.delete("/{task_id}", status_code=status.HTTP_200_OK)
def delete_task(
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
    TaskService.delete_task(db, task)
    return APIResponse(
        success=True,
        message="Task deleted successfully"
    )


@router.post("/{task_id}/complete", response_model=APIResponse[TaskResponse])
def complete_task(
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
    completed = TaskService.complete_task(db, task)
    return APIResponse(
        success=True,
        message="Task marked as completed",
        data=TaskResponse.model_validate(completed)
    )


@router.post("/{task_id}/cancel", response_model=APIResponse[TaskResponse])
def cancel_task(
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
    cancelled = TaskService.cancel_task(db, task)
    return APIResponse(
        success=True,
        message="Task cancelled successfully",
        data=TaskResponse.model_validate(cancelled)
    )
