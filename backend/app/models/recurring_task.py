import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base


class RecurringTask(Base):
    __tablename__ = "recurring_tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    repeat_type = Column(String(20), nullable=False)  # daily, weekly, monthly, yearly, custom
    interval = Column(Integer, nullable=False, default=1)
    start_at = Column(DateTime(timezone=True), nullable=False)
    end_at = Column(DateTime(timezone=True), nullable=True)
    next_run_at = Column(DateTime(timezone=True), nullable=False, index=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    task = relationship("Task", back_populates="recurring_config")
