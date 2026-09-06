# Architecture Documentation

## Overview

The Smart Personal Scheduler & Reminder System is engineered as a mobile-first, multi-user, multi-device enterprise platform.

## System Components Explained

### 1. Identity & Authentication Provider
- **WHAT**: Firebase Authentication.
- **WHY**: Provides secure, managed user identity, email verification, password reset, and Google Sign-In SDK support without custom password hashing risks.
- **HOW**: Flutter authenticates via Firebase client SDK -> Obtains Firebase ID Token -> Sends token in `Authorization: Bearer <id_token>` header to FastAPI -> FastAPI verifies signature using Firebase Admin SDK and maps `firebase_uid` to PostgreSQL `users` table.
- **WHERE**: Implement in `backend/app/core/firebase.py` and `backend/app/core/security.py`.
- **WHAT IF IT FAILS**: Requests with invalid or expired tokens are rejected at the FastAPI boundary with HTTP 401 Unauthorized before touching the database or business logic.

### 2. Business Logic & API Layer
- **WHAT**: Python FastAPI with Pydantic v2 and SQLAlchemy ORM.
- **WHY**: High performance async execution, automatic OpenAPI schema generation, strict type safety, and clean service layer separation.
- **HOW**: API routes validate inputs using Pydantic models, delegate business operations to dedicated services (`TaskService`, `ReminderService`), and interact with PostgreSQL.
- **WHERE**: Implemented in `backend/app/services/` and `backend/app/api/v1/routes/`.
- **WHAT IF IT FAILS**: Exceptions are intercepted by global middleware in `backend/app/main.py` returning sanitized JSON error responses with standard error codes.

### 3. Persistent Storage (Source of Truth)
- **WHAT**: PostgreSQL database managed via Alembic migrations.
- **WHY**: ACID compliant relational database handling user tasks, reminders, recurring rules, devices, and notification history.
- **HOW**: Timestamps are strictly stored in UTC (`TIMESTAMPTZ`). User preferred timezones are applied dynamically on presentation.
- **WHERE**: Defined in `backend/app/models/` and `backend/alembic/`.
- **WHAT IF IT FAILS**: Database connections use connection pooling with pre-ping validation to automatically reconnect on network hiccups.

### 4. Background Job Queue & Scheduling
- **WHAT**: Redis + Celery Worker + Celery Beat.
- **WHY**: Prevents blocking API requests, executes background reminder processing, and enforces idempotency so users never receive duplicate notifications.
- **HOW**: Celery Beat checks for due reminders every 30 seconds -> Enqueues Celery tasks -> Worker uses atomic SQL row locking (`SELECT FOR UPDATE SKIP LOCKED`) -> Dispatches push notification -> Updates status to `sent`.
- **WHERE**: Implemented in `backend/app/workers/celery_app.py` and `backend/app/workers/tasks.py`.
- **WHAT IF IT FAILS**: Task execution automatically retries with exponential backoff; missed jobs during downtime are picked up by the hourly recovery task.
