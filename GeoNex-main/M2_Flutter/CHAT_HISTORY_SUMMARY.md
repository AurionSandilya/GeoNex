# Risk-to-Action Platform — Chat & Project Summary

**Project Name**: Risk-to-Action — Landslide Risk Monitoring & Response Platform  
**Workspace**: `c:\Users\bably rangpi\Desktop\SIH`  
**Generated Date**: 2026-09-13  
**Framework**: Flutter 3.27.1 / Dart 3.6.0  

---

## 📌 Executive Summary

This document archives the entire development conversation, architectural decisions, pastel UI wireframe implementation, troubleshooting steps, and execution guidelines for the **Risk-to-Action** platform.

---

## 🏗️ System Architecture & Core Modules

The platform is structured into modular feature packages under `lib/`:

### 1. State & Mathematical Risk Engine
- **[`lib/state/app_state.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/state/app_state.dart)**: Central reactive state container handling dynamic risk calculation, offline report queue buffering, dynamic SOP generation, active alert triggers, and user authentication state.
- **Dynamic Feedback Loop**: When a field officer verifies a landslide or slope movement report, the engine triggers an automatic risk escalation (+15 score points) and propagates real-time recalculations to the dashboard, map, and alerts.

### 2. Design System & Pastel Color Tokens
- **[`lib/core/constants/app_colors.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/core/constants/app_colors.dart)**:
  - **High Risk**: `#FF8A8A` (Soft Coral) & `#FFEAEA` (Rose Tint)
  - **Moderate Risk**: `#FFC078` (Peach Amber) & `#FFF4E6` (Peach Cream)
  - **Low Risk**: `#69DB7C` (Sage Mint) & `#EBFBEE` (Mint Ice)
  - **Primary**: `#748FFC` (Periwinkle Blue) & `#EDF2FF` (Periwinkle Tint)
  - **Teal**: `#66D9E8` (Soft Cyan) & `#E3FAFC` (Cyan Ice)
  - **Purple**: `#B197FC` (Pastel Lilac) & `#F3F0FF` (Lilac Tint)
- **[`lib/app/theme.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/app/theme.dart)**: Light pastel theme with subtle elevations, soft card borders, and modern typography.

---

## 📱 15 Implemented Wireframe Screens

| Screen | File Location | Key Functionality |
| :--- | :--- | :--- |
| **Login & Role Switcher** | [`login_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/auth/login_screen.dart) | Instant demo login as Authority, Field Officer, or Citizen |
| **Main Dashboard** | [`dashboard_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/dashboard/dashboard_screen.dart) | 4 KPI metric cards, regional risk status gauge, sparkline, priority queue preview |
| **Risk Map** | [`risk_map_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/risk_map/risk_map_screen.dart) | Interactive vector map canvas with GIS layer toggles & location detail drawer |
| **Risk Details Assessment** | [`risk_details_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/risk_details/risk_details_screen.dart) | Pastel HIGH RISK 86/100 box, factor bars (Rainfall, Soil Moisture, Slope), Exposure Analysis |
| **Priority Queue** | [`priority_queue_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/priority/priority_queue_screen.dart) | Ranked location priority cards with severity filters |
| **Action Engine** | [`action_engine_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/actions/action_engine_screen.dart) | SOP recommended actions with step-by-step dispatch status |
| **Alerts Broadcast** | [`alerts_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/alerts/alerts_screen.dart) | Pastel warning cards with multi-channel tags (Push, SMS, Email, Broadcast) |
| **Citizen Field Reporting** | [`citizen_reporting_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/citizen_reporting/citizen_reporting_screen.dart) | Live camera viewfinder HUD with simulated GPS & timestamp metadata chips |
| **Offline Sync Queue** | [`offline_queue_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/offline_queue/offline_queue_screen.dart) | Offline network toggle, pending report buffer, and automated sync |
| **Field Verification** | [`field_verification_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/field_verification/field_verification_screen.dart) | Ground truth validation (Verify, Reject, Escalate) triggering feedback loop |
| **Risk-Aware Routing** | [`risk_aware_routing_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/risk_routing/risk_aware_routing_screen.dart) | Multi-route comparison (Route A Avoid, Route B Sage Mint Recommended, Route C Moderate) |
| **Region Analytics** | [`region_analytics_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/analytics/region_analytics_screen.dart) | Rainfall bar charts, slope stability sparklines, roadblock trends |
| **Risk History** | [`risk_history_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/history/risk_history_screen.dart) | Audit timeline log of historical risk levels |
| **Profile & Settings** | [`settings_screen.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/settings/settings_screen.dart) | User settings, map layer configuration, offline mode, language, sync |
| **Main Shell** | [`main_shell.dart`](file:///c:/Users/bably%20rangpi/Desktop/SIH/lib/features/shell/main_shell.dart) | Role-adaptive bottom navigation bar matching wireframe |

---

## 🔧 Resolved Issues & Configurations

### 1. Java 17 Requirement for Android Gradle Plugin
- **Problem**: `Android Gradle plugin requires Java 17 to run. You are currently using Java 11.`
- **Solution**:
  1. Configured Flutter to point to installed JDK 19:
     ```powershell
     & "C:\flutter\bin\flutter.bat" config --jdk-dir="C:\Program Files\Java\jdk-19"
     ```
  2. Set `org.gradle.java.home=C:\\Program Files\\Java\\jdk-19` in [`android/gradle.properties`](file:///c:/Users/bably%20rangpi/Desktop/SIH/android/gradle.properties).

### 2. Device Installation
- Successfully built `build/app/outputs/flutter-apk/app-debug.apk` and installed onto Samsung Galaxy `SM A266B` (Device ID: `RZCY31CDRXD`) via ADB.

---

## 🚀 How to Run and Test

### 1. Run on Connected Phone
```powershell
& "C:\flutter\bin\flutter.bat" run -d RZCY31CDRXD
```

### 2. Run in Desktop Browser (Chrome)
```powershell
& "C:\flutter\bin\flutter.bat" run -d chrome
```

### 3. Run Static Web Server
```powershell
python -m http.server 8080 --directory "c:\Users\bably rangpi\Desktop\SIH\build\web"
```
- Open `http://localhost:8080` on PC.
- Open `http://10.163.78.240:8080` on your phone browser.

### 4. Run Automated Tests
```powershell
& "C:\flutter\bin\flutter.bat" test
```
All unit and widget tests pass with 100% success rate.
