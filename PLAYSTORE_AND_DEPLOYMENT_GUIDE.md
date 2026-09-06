# 📱 BOTMARTZ AI — App Running, Play Store Setup & Deployment Guide

> **Project Directory**: `D:\ecommers\notification`  
> **GitHub Repository**: [https://github.com/sachinrawat6264384464/notifi_app.git](https://github.com/sachinrawat6264384464/notifi_app.git)

---

## 📌 1. Project Directory Structure (Kaha par kya hai?)

```
D:\ecommers\notification\
│
├── mobile/                            # Flutter Mobile & Web Application
│   ├── assets/icons/app_logo.png      # High-Res 3D BOTMARTZ AI App Logo (1024x1024)
│   ├── android/app/src/main/          # Android Manifest & Play Store config (Package: com.botmartz.notifi_app)
│   ├── build/web/                     # Compiled Production Web Bundle
│   ├── lib/                           # Flutter App UI Screens & Controllers
│   └── pubspec.yaml                   # App Dependencies & Launcher Icons config
│
├── backend/                           # FastAPI Python Backend Engine
│   ├── app/                           # REST APIs, SQLAlchemy Models, Celery Workers
│   ├── tests/                         # 100% Passing Integration Tests
│   └── requirements.txt               # Backend Python Dependencies
│
├── README.md                          # Main Project Overview
└── PLAYSTORE_AND_DEPLOYMENT_GUIDE.md  # Complete Deployment & Play Store Guide (This file)
```

---

## 🚀 2. Application Kaise Run Kare? (How to Run Locally)

### A. Web Application Run Karne Ke Liye (Fast & Production-Ready)

1. Open PowerShell / Command Prompt inside `D:\ecommers\notification\mobile`:
2. Run this command:
   ```bash
   python -m http.server 8095 --directory build/web
   ```
3. Browser me URL open kare:  
   👉 **`http://localhost:8095`**

---

### B. FastAPI Backend Run Karne Ke Liye

1. Open PowerShell inside `D:\ecommers\notification`:
2. Run Uvicorn server:
   ```bash
   $env:PYTHONPATH="backend"; python -m uvicorn app.main:app --reload --port 8000
   ```
3. Backend API status check kare:  
   👉 **`http://localhost:8000/health`** (Returns `{"status": "ok"}`)

---

## 📲 3. App Logo & Play Store Icons Setup (Kha par hai Logo?)

1. **Main High-Res Logo**:
   - Path: `mobile/assets/icons/app_logo.png`
   - Resolution: `1024x1024` Premium 3D BOTMARTZ AI Mesh Icon

2. **Generated Android Launcher Icons**:
   - `mobile/android/app/src/main/res/mipmap-hdpi/launcher_icon.png`
   - `mobile/android/app/src/main/res/mipmap-mdpi/launcher_icon.png`
   - `mobile/android/app/src/main/res/mipmap-xhdpi/launcher_icon.png`
   - `mobile/android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png`
   - `mobile/android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png`

3. **Generated iOS Launcher Icons**:
   - `mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 🛒 4. Play Store Par App Kaise Upload Kare? (Step-by-Step Play Store Guide)

### Step 1: OpenJDK 17 Install Kare (Android Build ke liye)
1. Download JDK 17: [Adoptium OpenJDK 17 Installer](https://adoptium.net)
2. Environment Variable `JAVA_HOME` set kare to `C:\Program Files\Eclipse Adoptium\jdk-17...`.

### Step 2: Play Store App Bundle (`.aab`) Generate Kare
1. Open PowerShell inside `D:\ecommers\notification\mobile`.
2. Run this build command:
   ```bash
   flutter build appbundle --release
   ```
3. Bundle file `mobile/build/app/outputs/bundle/release/app-release.aab` me generate hogi.

### Step 3: Google Play Console Par Upload Kare
1. Go to [Google Play Console](https://play.google.com/console).
2. **Create App** click kare.
   - App Name: `BOTMARTZ AI`
   - Default Language: `English`
   - App or Game: `App`
   - Free or Paid: `Free`
3. Left menu me **Production** ya **Internal Testing** -> **Create New Release** par click kare.
4. Generated `app-release.aab` file drag-and-drop upload kare.
5. App Logo (`mobile/assets/icons/app_logo.png`), Description, aur Screenshots upload karke **Save & Review Release** click kare.

---

## 🧪 5. Testing & Verification Commands

1. **Backend E2E Tests**:
   ```bash
   $env:PYTHONPATH="backend"; python -m pytest backend/tests -v
   ```
   *(Result: 11/11 Passed)*

2. **Flutter Code Analyzer**:
   ```bash
   cd mobile
   flutter analyze
   ```
   *(Result: No issues found! 0 Errors, 0 Warnings)*

3. **Flutter Widget Tests**:
   ```bash
   cd mobile
   flutter test
   ```
   *(Result: All tests passed!)*

---

## 🌐 6. GitHub Repository Links

- **GitHub Repository**: [github.com/sachinrawat6264384464/notifi_app](https://github.com/sachinrawat6264384464/notifi_app.git)
- **Branch**: `main`
