from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.core.firebase import verify_firebase_token
from app.services.user_service import UserService
from app.models.user import User
from app.core.logging import logger

security_bearer = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_bearer),
    db: Session = Depends(get_db)
) -> User:
    """
    Validates Firebase ID token from Authorization header (Bearer <token>).
    Finds or provisions user in PostgreSQL database based on verified Firebase UID.
    """
    token = credentials.credentials
    try:
        decoded_token = verify_firebase_token(token)
    except Exception as e:
        logger.error(f"Authentication token verification failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    firebase_uid = decoded_token.get("uid")
    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token payload missing UID",
        )

    email = decoded_token.get("email", f"{firebase_uid}@example.com")
    name = decoded_token.get("name", "User")

    # Get or auto-create user in PostgreSQL
    user = UserService.get_or_create_user(db, firebase_uid=firebase_uid, email=email, name=name)
    return user
