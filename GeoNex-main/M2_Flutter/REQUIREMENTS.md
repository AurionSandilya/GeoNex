# Project Requirements & Setup Guide

This document outlines everything required to install, configure, and run **SIH Risk-to-Action** on a new developer machine.

---

## 1. System & Hardware Requirements

| Component | Minimum | Recommended |
| :--- | :--- | :--- |
| **Operating System** | Windows 10/11 (64-bit), macOS, or Linux | Windows 11 / macOS |
| **Processor** | Dual-core x86_64 or Apple Silicon | Quad-core or higher |
| **Memory (RAM)** | 8 GB | 16 GB+ (especially for Android Emulator) |
| **Disk Space** | 5 GB free (excluding IDE & SDKs) | 10–15 GB free |

---

## 2. Software Prerequisites

Make sure the following software is installed on the machine:

### 1. Flutter SDK & Dart
- **Flutter SDK**: `3.6.0` or higher (Stable channel)
- **Dart SDK**: Included bundled with Flutter (`^3.6.0`)
- [Download Flutter SDK](https://docs.flutter.dev/get-started/install)

### 2. Version Control
- **Git**: [Download Git](https://git-scm.com/downloads)

### 3. Recommended Code Editors / IDEs
- **VS Code**: Install the official **Flutter** and **Dart** extensions.
- *OR* **Android Studio**: Install the **Flutter** and **Dart** plugins.

### 4. Platform-Specific Build Tools (Choose your target)

- **For Web (Easiest & Fastest for Testing)**:
  - Google Chrome / Chromium browser.
- **For Android**:
  - Android Studio with Android SDK Platform-Tools & Android Emulator (or physical Android device with USB debugging enabled).
  - Java Development Kit (JDK 17 or higher, included in modern Android Studio).
- **For Windows Desktop**:
  - Visual Studio 2022 with "Desktop development with C++" workload installed.

---

## 3. Project Dependencies

The project dependencies are managed via [`pubspec.yaml`](./pubspec.yaml):

```yaml
environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## 4. Step-by-Step Setup & Run Instructions

### Step 1: Clone or Copy the Repository
Open a terminal (PowerShell, Command Prompt, or Bash) and navigate to the project root:
```bash
cd sih_risk_to_action
```

### Step 2: Check Environment Health
Run the Flutter diagnostic tool to verify all required dependencies are met:
```bash
flutter doctor
```
*Ensure there are checkmarks (`[✓]`) for Flutter, your target platform (Chrome / Android / Windows), and your IDE.*

### Step 3: Install Flutter Dependencies
Download and link all project dependencies:
```bash
flutter pub get
```

### Step 4: Check Available Devices
Check which devices or emulators are connected and ready:
```bash
flutter devices
```

### Step 5: Run the Application

#### Option A: Run in Chrome (Fast Web Preview)
```bash
flutter run -d chrome
```

#### Option B: Run on Windows Desktop
```bash
flutter run -d windows
```

#### Option C: Run on Connected Android Device or Emulator
```bash
flutter run -d android
```

#### Option D: Let Flutter Prompt for Device
```bash
flutter run
```

---

## 5. Helpful Commands & Troubleshooting

| Issue / Task | Command / Solution |
| :--- | :--- |
| **Dependency Cache Error** | `flutter clean && flutter pub get` |
| **Analyze Code for Errors** | `flutter analyze` |
| **Run Unit / Widget Tests** | `flutter test` |
| **Android Licenses Warning** | Run `flutter doctor --android-licenses` and accept all |
| **Upgrade Flutter SDK** | `flutter upgrade` |

---

## 6. Project Architecture Overview
- **Entry Point**: [`lib/main.dart`](./lib/main.dart)
- **App Shell & Routing**: [`lib/app/`](./lib/app/)
- **Theme & Styling**: [`lib/app/theme.dart`](./lib/app/theme.dart)
- **Risk AI / Simulation Engine**: [`lib/ai/mock_risk_engine.dart`](./lib/ai/mock_risk_engine.dart)
- **Core Constants**: [`lib/core/constants/`](./lib/core/constants/)
- **UI Screens & Features**: [`lib/features/`](./lib/features/)
