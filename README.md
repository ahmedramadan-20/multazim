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

> 🚧 **Status:** Phase 5 complete + Auth & Cloud Sync. Local persistence with ObjectBox, remote sync with Supabase.

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

- **Authentication** — Email/password login and sign-up via Supabase with auth state persistence and session management.
- **Cloud Sync** — Bi-directional data sync between local ObjectBox and remote Supabase with conflict resolution (version-based).
- **Habit Management** — CRUD for habits with customizable icons, colors, and difficulty.
- **Advanced Scheduling** — Daily habits or "X times per week" (ISO-week compliant).
- **Goal Types** — Binary (Yes/No) or Quantitative (e.g., "500ml water", "10 pages read").
- **Streak Engine** — Sophisticated streak tracking with three algorithms (Perfect, Flexible, Consistency), automatic repairs, and milestone generation.
- **Analytics Dashboard** — Advanced visualization with `fl_chart`:
    - **Completion Trends**: 30-day line chart of performance.
    - **Heatmap Calendar**: Year-view of habit consistency.
    - **Metric Cards**: "Perfect Days", "Best Performance Day", "Active Streaks".
- **Smart Insights** — Automated feedback on consistency, performance trends, and milestone-based streak records.
- **Arabic UI** — Full RTL and localized content for all features.
- **App Icons** — Custom branded icons for both Android and iOS.

---

## ⚡ Performance Optimizations

- **Batch Data Fetching** — `HabitsCubit.loadHabits()` uses 3 batch queries instead of 4×N per-habit queries (N+1 elimination).
- **Batch Sync** — `SyncService` fetches all milestones and streak repairs in a single network call per entity type.
- **O(N+W) Streak Algorithm** — Consistency streak calculation uses a pointer-based sliding window instead of O(N×W) nested scans.
- **Milestone-Based Insights** — "New Record" insight fires only at notable thresholds (7, 14, 21, 30, 50, 100…) to prevent daily spam.
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
| 1 | Core Habit Loop (CRUD, tracking, ObjectBox) | ✅ Complete |
| 2-3 | Analytics Dashboard & Charts | ✅ Complete |
| 4 | Insights & Smart Feedback | ✅ Complete |
| 5 | Goals, Streaks & UX Overhaul | ✅ Complete |
| 5.5 | Auth, Cloud Sync & Performance | ✅ Complete |
| 6 | Gamification (Levels, XP, Rewards) | 🔜 Next |
| 7 | Social Features | 🔜 Planned |

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
