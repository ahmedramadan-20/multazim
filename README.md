<div align="center">

# ملتزم — Multazim

**A habit tracking app built with Flutter & Clean Architecture**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📖 Overview

**Multazim** (ملتزم — "committed") is a habit tracking app designed to help users build and maintain positive daily habits. Built with **Clean Architecture** principles in Flutter, it emphasizes separation of concerns, testability, and scalability.

> 🚧 **Status:** Phase 5.8 Complete — Full Dark Mode Support + Branded Splash & Icons + Enhanced Background Notifications.

---

## 🏗️ Architecture

The app follows **feature-based Clean Architecture** with three layers:

```
lib/
├── core/                         # Cross-cutting concerns
│   ├── data/                     # ObjectBoxStore helper
│   ├── di/                       # GetIt dependency injection
│   ├── error/                    # Failures & Exceptions
│   ├── router/                   # GoRouter configuration
│   ├── services/                 # ConnectivityService
│   ├── theme/                    # AppTheme, AppColors
│   └── utils/                    # DateTime extensions
│
├── features/
│   ├── auth/                     # Authentication
│   │   ├── domain/               # User entity, AuthRepository, UseCases
│   │   ├── data/                 # SupabaseAuthDatasource, AuthRepositoryImpl
│   │   └── presentation/        # AuthCubit, LoginPage, SignUpPage
│   │
│   ├── habits/
│   │   ├── domain/               # Pure Dart logic
│   │   │   ├── entities/         # Habit, HabitEvent, Streak, Milestone
│   │   │   ├── services/         # StreakService, SyncService, WeeklyProgress
│   │   │   └── usecases/         # CreateHabit, CompleteHabit, BatchFetch, etc.
│   │   ├── data/                 # Data implementations
│   │   │   ├── models/           # HabitModel, StreakRepairModel
│   │   │   ├── datasources/     # ObjectBox (local), Supabase (remote)
│   │   │   └── repositories/     # HabitRepositoryImpl
│   │   └── presentation/         # UI & State
│   │       ├── cubit/            # HabitsCubit
│   │       ├── helpers/          # Translation Helpers
│   │       ├── widgets/          # HabitCard
│   │       └── pages/            # TodayPage, CreateHabitPage
│   │
│   └── analytics/
│       ├── domain/               # Analytics logic
│       │   ├── entities/         # DailySummary, Insight
│       │   └── services/         # InsightGenerator
│       └── presentation/         # Analytics UI
│           ├── cubit/            # AnalyticsCubit
│           └── widgets/          # Heatmap, Trend Charts
│
└── main.dart
```

### Data Flow

```
UI (Widget) → Cubit → UseCase → Repository (interface) → DataSource → ObjectBox / Supabase
```

---

## ✅ Features

- **Authentication** — Secure login/sign-up via Supabase with persistent sessions.
- **Cloud Sync** — Seamless background synchronization with guest-to-account migration and connectivity awareness.
- **Habit Management** — Complete CRUD with customizable attributes and dynamic completion logic.
- **Advanced Scheduling** — ISO-week compliant scheduling for flexible frequency habits.
- **Streak Engine (v2)** — Re-engineered streak calculations with Flexible and Consistency algorithms and automatic milestone generation.
- **Analytics Dashboard** — High-performance charts using `fl_chart`, including heatmaps and contribution trends.
- **Smart Insights** — Dynamic feedback based on performance history and streak records.
- **Dark Mode Support** — Semantic color system following Material 3 guidelines for a premium dark experience.
- **Branded Assets** — Custom-designed app icons and native splash screens for Android and iOS.
- **Arabic Localization** — Full RTL support with Cairo typography and localized functional text.
- **Reliable Notifications** — Exact alarm scheduling for reminders that persist across app restarts and system reboots.
---

## ⚡ Performance Optimizations

- **Background Sync Listener** — Uses `connectivity_plus` to automatically trigger data synchronization as soon as internet connectivity is restored, without requiring app interaction.
- **Guest-to-Account Migration** — Atomic push-before-pull strategy during sign-up ensures guest habits are uploaded before account data is merged.
- **Batch Data Fetching** — `HabitsCubit.loadHabits()` uses 3 batch queries instead of 4×N per-habit queries (N+1 elimination).
- **Batch Sync** — `SyncService` fetches all milestones and streak repairs in a single network call per entity type.
- **O(N+W) Streak Algorithm** — Consistency streak calculation uses a pointer-based sliding window instead of O(N×W) nested scans.
- **Static Color Parsing** — `HabitCard` color parsing extracted to a static helper to avoid re-computation on every widget rebuild.

---

## ✨ Design & UX

The app follows modern design principles to provide a premium and tactile experience:
- **Premium Aesthetics** — Vibrant colors, Material 3, and harmonious palettes generated from seeds.
- **Depth & Dimension** — Multi-layered drop shadows and card elevations.
- **Micro-animations** — Shimmer loading states and interactive transitions.
- **Arabic-First** — Cairo font, RTL layout, fully localized UI.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | Flutter (Material 3) |
| **State Management** | flutter_bloc (Cubit) |
| **Local Persistence** | ObjectBox |
| **Remote Backend** | Supabase (Auth + Database) |
| **Visualization** | fl_chart (Heatmaps & Trends) |
| **Navigation** | GoRouter |
| **Dependency Injection** | get_it |
| **Localization** | intl |
| **Branding** | flutter_launcher_icons |
| **ID Generation** | uuid |
| **Environment** | flutter_dotenv |
| **Connectivity** | connectivity_plus |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+
- A Supabase project (for auth and cloud sync)

### Installation

```bash
# Clone the repository
git clone https://github.com/ahmedramadan-20/multazim.git
cd multazim

# Create a .env file with your Supabase credentials
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key

# Install dependencies
flutter pub get

# Generate ObjectBox code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 🗺️ Roadmap

| Phase | Feature | Status |
|-------|---------|--------|
| 1-4 | Core Tracking, Analytics & Insights | ✅ Complete |
| 5 | Goals, Streaks & UX Overhaul | ✅ Complete |
| 5.5 | Auth & Cloud Sync | ✅ Complete |
| 5.8 | UI Refactor, Dark Mode & Notifications | ✅ Complete |
| 6 | Gamification (Levels, XP, Rewards) | 🔜 Next |
| 7 | Social Features & Group Habits | 🔜 Planned |

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
