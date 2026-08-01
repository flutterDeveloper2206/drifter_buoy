# Drifter Buoy

Cross-platform mobile application for monitoring, managing, and exporting drifter buoy data. Built with Flutter for Android and iOS.

## Author & Contact

> ### ⭐ **Keval Buha**
>
> **Lead / Primary Developer**  
> Fullstack Developer — Flutter, Android, iOS, Web
>
> | | |
> |---|---|
> | **Email** | [**gbuha12345@gmail.com**](mailto:gbuha12345@gmail.com) |
> | **Phone** | [**+91 9925130170**](tel:+919925130170) |

---

**Kishan Dobariya**  
Fullstack Developer — Flutter, Android, iOS, Web

| | |
|---|---|
| **Email** | [kishup713@gmail.com](mailto:kishup713@gmail.com) |
| **Phone** | [+91 9023256218](tel:+919023256218) |
| **LinkedIn** | [linkedin.com/in/kishan-dobariya-99b005217](https://www.linkedin.com/in/kishan-dobariya-99b005217/) |

---

## License

Private project — not published to pub.dev.

**Current version:** `1.0.1` (build `2`)

## Overview

Drifter Buoy helps field teams and administrators track buoy status, view trajectories on a map, analyze metrics, export reports, and configure devices. The app supports role-based access for **General Users** and **Admins**.

## Features

- **Authentication** — Login, forgot password, and secure session handling
- **Dashboard** — Buoy overview, alerts, and key metrics at a glance
- **Buoys** — List, search, and detailed buoy data views
- **Map** — Interactive buoy map with filters and buoy details
- **Trajectory** — Trajectory visualization and filtering
- **Export** — Buoy status export (PDF and share flows)
- **Setup (Admin)** — Device setup and configuration via Bluetooth
- **Profile** — User profile management
- **Push notifications** — Firebase Cloud Messaging integration
- **Offline handling** — Connectivity checks and no-internet UX

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart SDK `^3.9.0`) |
| State management | `flutter_bloc` |
| Navigation | `go_router` |
| Networking | `dio` |
| Maps | `google_maps_flutter`, `flutter_map` |
| Charts | `fl_chart`, Syncfusion DatePicker |
| Push | Firebase Core & Messaging |
| BLE | `flutter_blue_plus` |
| DI | `get_it` |

## Project Structure

```
lib/
├── core/                 # Shared utilities, network, routing, widgets
└── features/
    └── general_user/     # Auth, dashboard, buoys, map, export, setup, etc.
        ├── data/
        ├── domain/
        └── presentation/
```

Architecture follows **Clean Architecture** with separation into data, domain, and presentation layers.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart `^3.9.0`
- Android Studio / Xcode for platform tooling
- Firebase project configured (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
# Debug
flutter run

# Android release APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS release
flutter build ios --release
```

### App launcher icons

Regenerate launcher icons after updating `assets/icons/ic_logo.png`:

```bash
dart run flutter_launcher_icons
```

## Android

| Property | Value |
|----------|-------|
| App name | Drifter Buoy |
| Application ID | `com.drifter_buoy.app` |
| Version name | `1.0.1` |
| Version code | `2` |

## Testing

Final UAT was performed with **Amey Vandre** against APK version **1.0.1**.

---


