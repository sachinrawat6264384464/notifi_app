from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import hash_password, verify_password, create_access_token, get_current_user
from app.models import User
from app.schemas.user import UserResponse
from app.schemas.response import APIResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str
    timezone: str = "UTC"


class AuthTokenData(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


@router.post("/register", response_model=APIResponse[AuthTokenData], status_code=status.HTTP_201_CREATED)
def register_user(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == req.email.lower().strip()).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    user = User(
        name=req.name.strip(),
        email=req.email.lower().strip(),
        hashed_password=hash_password(req.password.strip()),
        timezone=req.timezone
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(user.id, user.email)
    return APIResponse(
        success=True,
        message="Registration successful",
        data=AuthTokenData(
            access_token=token,
            token_type="bearer",
            user=UserResponse.model_validate(user)
        )
    )


@router.post("/login", response_model=APIResponse[AuthTokenData])
def login_user(req: LoginRequest, db: Session = Depends(get_db)):
    email_clean = req.email.lower().strip()
    user = db.query(User).filter(User.email == email_clean).first()
    if not user or not verify_password(req.password.strip(), user.hashed_password or ""):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    token = create_access_token(user.id, user.email)
    return APIResponse(
        success=True,
        message="Login successful",
        data=AuthTokenData(
            access_token=token,
            token_type="bearer",
            user=UserResponse.model_validate(user)
        )
    )


@router.get("/me", response_model=APIResponse[UserResponse])
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return APIResponse(
        success=True,
        message="User profile retrieved",
        data=UserResponse.model_validate(current_user)
    )
