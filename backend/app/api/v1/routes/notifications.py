import math
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.notification import NotificationResponse, NotificationPaginatedResponse
from app.schemas.response import APIResponse
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("", response_model=APIResponse[NotificationPaginatedResponse])
def get_user_notifications(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    items, total, unread_count = NotificationService.get_user_notifications(
        db, current_user.id, page=page, page_size=page_size
    )
    return APIResponse(
        success=True,
        message="Notifications retrieved successfully",
        data=NotificationPaginatedResponse(
            items=[NotificationResponse.model_validate(n) for n in items],
            total=total,
            page=page,
            page_size=page_size,
            unread_count=unread_count
        )
    )


@router.post("/{id}/read", response_model=APIResponse[NotificationResponse])
def mark_notification_read(
    id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    notif = NotificationService.mark_as_read(db, current_user.id, id)
    if not notif:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found or access denied"
        )
    return APIResponse(
        success=True,
        message="Notification marked as read",
        data=NotificationResponse.model_validate(notif)
    )


@router.post("/read-all", response_model=APIResponse[dict])
def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    updated_count = NotificationService.mark_all_as_read(db, current_user.id)
    return APIResponse(
        success=True,
        message=f"{updated_count} notifications marked as read",
        data={"updated_count": updated_count}
    )
