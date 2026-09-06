# Database Documentation

## Persistent Source of Truth

PostgreSQL is the single source of truth for the entire application stack.

## Table Schemas & Indexes

### 1. `users`
- `id` (UUID, Primary Key)
- `firebase_uid` (VARCHAR 128, UNIQUE, Indexed)
- `name` (VARCHAR 255)
- `email` (VARCHAR 255, UNIQUE, Indexed)
- `timezone` (VARCHAR 64, Default 'UTC')
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 2. `tasks`
- `id` (UUID, Primary Key)
- `user_id` (UUID, FK -> users.id, Indexed)
- `title` (VARCHAR 255)
- `description` (TEXT)
- `due_at` (TIMESTAMPTZ, Indexed)
- `priority` (VARCHAR 20, Default 'medium')
- `category` (VARCHAR 50)
- `status` (VARCHAR 20, Default 'pending', Indexed)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 3. `reminders`
- `id` (UUID, Primary Key)
- `task_id` (UUID, FK -> tasks.id, Indexed)
- `reminder_at` (TIMESTAMPTZ, Indexed)
- `reminder_type` (VARCHAR 50)
- `status` (VARCHAR 20, Default 'pending', Indexed)
- `sent_at` (TIMESTAMPTZ)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 4. `recurring_tasks`
- `id` (UUID, Primary Key)
- `task_id` (UUID, FK -> tasks.id, Indexed)
- `repeat_type` (VARCHAR 20)
- `interval` (INTEGER, Default 1)
- `start_at` (TIMESTAMPTZ)
- `end_at` (TIMESTAMPTZ)
- `next_run_at` (TIMESTAMPTZ, Indexed)
- `is_active` (BOOLEAN, Default True)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 5. `notifications`
- `id` (UUID, Primary Key)
- `user_id` (UUID, FK -> users.id, Indexed)
- `task_id` (UUID, FK -> tasks.id)
- `reminder_id` (UUID, FK -> reminders.id)
- `title` (VARCHAR 255)
- `body` (TEXT)
- `status` (VARCHAR 20, Default 'pending')
- `sent_at` (TIMESTAMPTZ)
- `created_at` (TIMESTAMPTZ)

### 6. `devices`
- `id` (UUID, Primary Key)
- `user_id` (UUID, FK -> users.id, Indexed)
- `fcm_token` (VARCHAR 512, UNIQUE, Indexed)
- `platform` (VARCHAR 20)
- `device_name` (VARCHAR 255)
- `last_active_at`, `created_at`, `updated_at` (TIMESTAMPTZ)

---

## Migration Workflow (Alembic)
```bash
# Generate new migration script
alembic revision --autogenerate -m "Add index"

# Upgrade database to latest revision
alembic upgrade head
```
