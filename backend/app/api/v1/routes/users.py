from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate
from app.schemas.response import APIResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=APIResponse[UserResponse])
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return APIResponse(
        success=True,
        message="User profile retrieved successfully",
        data=UserResponse.model_validate(current_user)
    )


@router.patch("/me", response_model=APIResponse[UserResponse])
def update_user_profile(
    update_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    updated_user = UserService.update_user_profile(db, current_user, update_data)
    return APIResponse(
        success=True,
        message="User profile updated successfully",
        data=UserResponse.model_validate(updated_user)
    )
