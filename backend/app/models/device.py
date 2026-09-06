import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base


class Device(Base):
    __tablename__ = "devices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    fcm_token = Column(String(512), unique=True, nullable=False, index=True)
    platform = Column(String(20), nullable=False)  # android, ios
    device_name = Column(String(255), nullable=True)
    last_active_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="devices")
