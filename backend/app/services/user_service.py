from typing import Optional
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserUpdate
from app.core.logging import logger


class UserService:
    @staticmethod
    def get_user_by_firebase_uid(db: Session, firebase_uid: str) -> Optional[User]:
        return db.query(User).filter(User.firebase_uid == firebase_uid).first()

    @staticmethod
    def get_or_create_user(
        db: Session,
        firebase_uid: str,
        email: str,
        name: str,
        timezone: str = "UTC"
    ) -> User:
        user = UserService.get_user_by_firebase_uid(db, firebase_uid)
        if not user:
            logger.info(f"Auto-provisioning new user for Firebase UID: {firebase_uid}")
            user = User(
                firebase_uid=firebase_uid,
                email=email,
                name=name or "Scheduler User",
                timezone=timezone
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        return user

    @staticmethod
    def update_user_profile(db: Session, user: User, update_data: UserUpdate) -> User:
        if update_data.name is not None:
            user.name = update_data.name
        if update_data.timezone is not None:
            user.timezone = update_data.timezone
        db.commit()
        db.refresh(user)
        return user
