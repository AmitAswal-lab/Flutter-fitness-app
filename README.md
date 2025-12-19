# Fitness App 🏃‍♂️

A Flutter fitness tracking app built with **Clean Architecture** and **BLoC** pattern.

## Features

- 🔐 **Authentication** - Email/password sign in & sign up with Firebase
- 👟 **Step Tracking** - Real-time pedometer with daily/weekly stats
- 👤 **User Profile** - Height, weight, DOB, gender with BMI calculation
- 🧪 **Simulator Support** - Mock pedometer for iOS/Android simulator testing

## Architecture

```
lib/
├── core/                    # Shared utilities
│   ├── constants/           # App colors
│   ├── entities/            # UserEntity
│   ├── error/               # Failure classes
│   ├── theme/               # AppTheme
│   └── utils/               # DeviceUtils
│
├── features/
│   ├── auth/                # Authentication feature
│   │   ├── data/            # DataSources, Models, RepositoryImpl
│   │   ├── domain/          # Entities, Repository, UseCases
│   │   └── presentation/    # BLoC, Pages, Widgets
│   │
│   ├── profile/             # User profile feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── steps/               # Step tracking feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── dashboard/           # Homepage
│
└── injection_container.dart # GetIt dependency injection
```

## Tech Stack

| Category         | Technology         |
| ---------------- | ------------------ |
| Framework        | Flutter 3.x        |
| State Management | flutter_bloc       |
| DI               | get_it             |
| Error Handling   | fpdart (Either)    |
| Auth             | firebase_auth      |
| Storage          | shared_preferences |
| Pedometer        | pedometer          |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Download and add config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

## Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Development Notes

### Simulator Testing

The app auto-detects iOS/Android simulators and uses a mock pedometer that simulates step counting. This allows testing profile and other features without activity recognition permissions.
