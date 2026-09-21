# SIH Risk-to-Action Application

A Flutter-based decision intelligence and risk mitigation application for the Smart India Hackathon (SIH).

---

## 📋 Requirements & Prerequisites

For detailed hardware, software, and platform setup instructions, see [REQUIREMENTS.md](file:///c:/Users/bably%20rangpi/Desktop/SIH/REQUIREMENTS.md).

### Quick Prerequisites
- **Flutter SDK**: `^3.6.0` (Dart SDK bundled)
- **Git**
- **Google Chrome** (for quick web preview), **Android Studio** (for Android), or **VS Build Tools** (for Windows)

---

## 🚀 Quick Start Guide

1. **Clone/Download the repository**
2. **Verify environment setup**:
   ```bash
   flutter doctor
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   - Web (Chrome):
     ```bash
     flutter run -d chrome
     ```
   - Windows Desktop:
     ```bash
     flutter run -d windows
     ```
   - Android Emulator/Device:
     ```bash
     flutter run -d android
     ```

---

## 🛠️ Project Structure
- [`lib/main.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/main.dart): Application entry point
- [`lib/app/`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/app): Global configuration, router, and themes
- [`lib/ai/`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/ai): AI risk assessment and simulation engines
- [`lib/core/`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/core): Core constants, theme tokens, and utilities
- [`lib/features/`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features): Feature modules (Dashboard, Alerts, Risk Map, Actions, etc.)

