# Flexit Admin App

A premium Flutter admin dashboard for the Flexit Menu Management platform.

## Features
- 🔐 Login with email & password
- 📊 Dashboard with live stats (Users, Devices, Revenue, Errors)
- 👥 Customer management with search, filter, ban, plan extension
- 📱 Device registry with full device specs
- 💰 Payment/income history with transaction details
- 🐛 Error log with stack traces and resolution actions
- 🌗 Dark / Light / System theme support

## Setup

1. Make sure Flutter SDK is installed (>=3.0.0)
2. Place this folder in your workspace
3. Run:

```bash
cd flexit_admin
flutter pub get
flutter run
```

## Demo Login
- Email: `admin@flexit.io`
- Password: `admin123`

## Folder Structure
```
lib/
├── main.dart
├── core/
│   ├── models/models.dart          # All data models
│   ├── theme/
│   │   ├── app_theme.dart          # Dark/light themes + color tokens
│   │   └── theme_provider.dart     # InheritedWidget theme switcher
│   └── utils/
│       ├── mock_data.dart          # Sample data
│       └── utils.dart              # Formatters, color helpers
├── screens/
│   ├── auth/login_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── users/
│   │   ├── users_screen.dart
│   │   └── user_detail_screen.dart
│   ├── devices/devices_screen.dart
│   ├── income/income_screen.dart
│   └── errors/errors_screen.dart
└── widgets/
    ├── common/common_widgets.dart  # Shared UI components
    └── dashboard/
        ├── stat_card.dart
        └── analytics_chart.dart    # Custom canvas chart
```
