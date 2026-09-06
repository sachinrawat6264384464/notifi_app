# 📱 BOTMARTZ AI — App Running, Play Store Setup & Deployment Guide

> **Project Directory**: `D:\ecommers\notification`  
> **GitHub Repository**: [https://github.com/sachinrawat6264384464/notifi_app.git](https://github.com/sachinrawat6264384464/notifi_app.git)

---

## 🎁 Ready Release Files (Direct Download & Install)

Trained and compiled native Android production files are available in:  
📁 **`D:\ecommers\notification\release_builds\`**

1. **`BOTMARTZ_AI_v1.0.0.apk`** (53.9 MB)  
   👉 **Android Phone Install File**: Copy this file to your Android phone via WhatsApp, Drive, or USB to directly install and use the app.

2. **`BOTMARTZ_AI_v1.0.0.aab`** (52.9 MB)  
   👉 **Google Play Console Upload File**: Upload this Android App Bundle (`.aab`) to your Google Play Console to publish on Play Store.

---

## 📌 Directory Structure

```
D:\ecommers\notification\
│
├── release_builds/
│   ├── BOTMARTZ_AI_v1.0.0.apk         # Ready-to-Install Android APK (53.9 MB)
│   └── BOTMARTZ_AI_v1.0.0.aab         # Google Play Store App Bundle (52.9 MB)
│
├── mobile/                            # Flutter Mobile & Web Application
│   ├── assets/icons/app_logo.png      # High-Res 3D BOTMARTZ AI App Logo (1024x1024)
│   ├── android/app/src/main/          # Android Manifest & Play Store config (Package: com.botmartz.notifi_app)
│   └── build/web/                     # Compiled Production Web Bundle
│
├── backend/                           # FastAPI Python Backend Engine
└── PLAYSTORE_AND_DEPLOYMENT_GUIDE.md  # Complete Deployment & Play Store Guide (This file)
```

---

## 🚀 How to Run Locally

### A. Web Application
```bash
cd D:\ecommers\notification\mobile
python -m http.server 8095 --directory build/web
```
👉 Open browser at: **`http://localhost:8095`**

### B. FastAPI Backend
```bash
cd D:\ecommers\notification
$env:PYTHONPATH="backend"; python -m uvicorn app.main:app --reload --port 8000
```
👉 Check backend health: **`http://localhost:8000/health`**

---

## 🛒 Google Play Console Upload Steps

1. Open [Google Play Console](https://play.google.com/console).
2. Click **Create App** -> App Name: **`BOTMARTZ AI`**.
3. Select **Production** -> **Create New Release**.
4. Drag and drop **`D:\ecommers\notification\release_builds\BOTMARTZ_AI_v1.0.0.aab`**.
5. Upload Store Icon (`mobile/assets/icons/app_logo.png`) and submit for review.
