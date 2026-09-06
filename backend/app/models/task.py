import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    due_at = Column(DateTime(timezone=True), nullable=False, index=True)
    priority = Column(String(20), nullable=False, default="medium")  # low, medium, high, urgent
    category = Column(String(50), nullable=True)
    status = Column(String(20), nullable=False, default="pending", index=True)  # pending, in_progress, completed, overdue, cancelled
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="tasks")
    reminders = relationship("Reminder", back_populates="task", cascade="all, delete-orphan")
    recurring_config = relationship("RecurringTask", back_populates="task", uselist=False, cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="task", cascade="all, delete-orphan")
