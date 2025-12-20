# Fitness App 🏃‍♂️

A Flutter fitness tracking app built with **Clean Architecture** and **BLoC** pattern.

## Features

- 🔐 **Authentication** - Email/password sign in & sign up with Firebase
- 👟 **Step Tracking** - Real-time pedometer with user-isolated data
- 📊 **Step Details Page** - Daily goal, calories, distance, active minutes
- 📈 **Weekly History** - 7-day bar chart with auto-archived daily totals
- 🎯 **Customizable Step Goal** - Set your own daily target (1k-30k)
- 🏋️ **Workout Library** - 6 pre-built templates (Strength, HIIT, Cardio, Core) with 20 exercises
- 👤 **User Profile** - Height, weight, DOB, gender with BMI calculation
- 🔥 **Profile-Based Calculations** - Personalized calories (MET formula) & distance (stride from height)
- 🧪 **Simulator Support** - Mock pedometer for iOS/Android simulator testing

## Screenshots

| Homepage                         | Step Details              |
| -------------------------------- | ------------------------- |
| Minimal step card, tap to expand | Full stats + weekly chart |

## Architecture

```
lib/
├── core/                    # Shared utilities
│   ├── constants/           # App colors
│   ├── entities/            # UserEntity
│   ├── error/               # Failure classes
│   ├── theme/               # AppTheme
│   ├── utils/               # DeviceUtils, FitnessCalculator
│   └── widgets/             # LifecycleObserver
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
│   │   ├── data/            # Pedometer, LocalDatasource, History
│   │   ├── domain/
│   │   └── presentation/    # StepCounterCard, StepDetailsPage, WeeklyChart
│   │
│   ├── workout/             # Workout feature (NEW)
│   │   ├── data/            # Models, Sample data, RepositoryImpl
│   │   ├── domain/          # Exercise, WorkoutTemplate, WorkoutSession
│   │   └── presentation/    # (Coming soon)
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

### Step Calculations

| Metric   | Formula                                           |
| -------- | ------------------------------------------------- |
| Distance | `steps × stride_length` (stride = height × 0.414) |
| Calories | MET formula: `METs × 3.5 × weight × time / 200`   |

### User-Specific Data

All step data is stored with user-specific keys (`cached_steps_${userId}`) to ensure data isolation when switching accounts.

### Simulator Testing

The app auto-detects iOS/Android simulators and uses a mock pedometer that simulates step counting.
