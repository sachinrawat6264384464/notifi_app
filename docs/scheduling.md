# Reminder Scheduling Engine & AI Integration Readiness

## Scheduling & Recovery Architecture

### 1. Idempotent Celery Execution
- Background tasks lock the target row before processing (`SELECT ... FOR UPDATE SKIP LOCKED`).
- If a task execution is attempted twice, the second worker sees `status == 'processing'` or `status == 'sent'` and exits cleanly.

### 2. Missed Reminder Recovery Policy
- Periodic Beat task scans for pending reminders where `reminder_at <= NOW()`.
- Reminders missed within the last 24 hours (due to server restart or network downtime) are immediately delivered.
- Reminders older than 24 hours or for completed tasks are marked `expired`.

---

## Future AI & LLM Integration Readiness

The backend service layer is completely decoupled from FastAPI HTTP routers. Future AI agents (e.g. LangChain, AutoGen, LlamaIndex, MCP tools) can directly invoke backend services:

```python
# Future AI Tool Integration Example
from app.services.task_service import TaskService
from app.schemas.task import TaskCreate

def ai_create_task_tool(user, title: str, due_at: datetime, reminder_offsets: List[int]):
    reminders = [{"reminder_type": "custom", "offset_minutes": m} for m in reminder_offsets]
    task_in = TaskCreate(title=title, due_at=due_at, reminders=reminders)
    return TaskService.create_task(db, user, task_in)
```
