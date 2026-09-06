import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    reminder_at = Column(DateTime(timezone=True), nullable=False, index=True)
    reminder_type = Column(String(50), nullable=False)  # custom, 7_days_before, 3_days_before, 1_day_before, 2_hours_before, 30_minutes_before, exact_time
    status = Column(String(20), nullable=False, default="pending", index=True)  # pending, processing, sent, failed, cancelled, expired
    sent_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    task = relationship("Task", back_populates="reminders")
    notifications = relationship("Notification", back_populates="reminder", cascade="all, delete-orphan")
