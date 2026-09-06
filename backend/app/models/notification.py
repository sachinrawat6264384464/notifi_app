import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="SET NULL"), nullable=True)
    reminder_id = Column(UUID(as_uuid=True), ForeignKey("reminders.id", ondelete="SET NULL"), nullable=True)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    status = Column(String(20), nullable=False, default="pending")  # pending, sent, failed, read
    sent_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="notifications")
    task = relationship("Task", back_populates="notifications")
    reminder = relationship("Reminder", back_populates="notifications")
