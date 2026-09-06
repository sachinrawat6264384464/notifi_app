# BOTMARTZ AI SOLUTIONS — Personal Scheduler & Notification App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql)](https://postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7.x-DC382D?logo=redis)](https://redis.io)

An enterprise-grade personal scheduling and smart notification platform designed with modern SaaS aesthetics (White + Light Blue + Dark Navy palette).

---

## 🌟 Key Features

* **Intelligent Lead Time Calculations**: Presets for 7 days, 3 days, 1 day, 2 hours, 30 minutes, and exact time lead-times.
* **Master SaaS UI/UX**: White base (`#FFFFFF`), soft blue highlights (`#F0F7FF`), 1px crisp borders (`#E4EDF5`), dark navy typography (`#0B1F33`), and interactive community announcement banners.
* **Authentication**: Seamless Firebase Auth token verification with offline dev fallback.
* **Backend Architecture**: FastAPI RESTful API, SQLAlchemy ORM, PostgreSQL database, and async Celery background worker with Redis.

---

## 🚀 Quick Start

### 1. Backend Setup (FastAPI & PostgreSQL)

```bash
cd backend
python -m venv venv
# Activate virtual environment
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### 2. Mobile Setup (Flutter)

```bash
cd mobile
flutter pub get
flutter run -d chrome
```

---

## 🧪 Verification & Testing

```bash
# Run backend integration tests
PYTHONPATH=backend python -m pytest backend/tests

# Run Flutter static analysis & unit tests
cd mobile
flutter analyze
flutter test
```
