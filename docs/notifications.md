# Notification & Authentication Flow Documentation

## Authentication Flow

```
Flutter Mobile Client
       │
       ▼
Firebase Authentication (Email/Password or Google)
       │
       ▼ Returns Firebase ID Token
Flutter attaches header: Authorization: Bearer <firebase_id_token>
       │
       ▼
FastAPI Middleware (verify_id_token using Firebase Admin SDK)
       │
       ▼
Extract firebase_uid -> Lookup in PostgreSQL users table -> Auto-provision if missing -> Execute Service
```

## Push Notification Delivery Flow

```
Celery Beat Timer (30s)
       │
       ▼
Queries PostgreSQL for due pending reminders
       │
       ▼
Celery Worker acquires row lock (FOR UPDATE SKIP LOCKED)
       │
       ▼
Queries user active FCM tokens from devices table
       │
       ▼
Calls Firebase Admin SDK messaging.send()
       │
       ▼
Pushes payload to User Devices (Android / iOS)
       │
       ▼
Updates reminder status to 'sent' and logs history in notifications table
```
