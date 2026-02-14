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

> 🚧 **Status:** Phase 5 (Goals & Streaks) is complete. Local-only persistence with ObjectBox.

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
│   ├── habits/
│   │   ├── domain/               # Pure Dart logic
│   │   │   ├── entities/         # Habit, HabitEvent, Streak, Milestone
│   │   │   ├── services/         # StreakService, WeeklyProgressService
│   │   │   └── usecases/         # CreateHabit, CompleteHabit, etc.
│   │   ├── data/                 # Data implementations
│   │   │   ├── models/           # HabitModel, StreakRepairModel
│   │   │   └── repositories/     # HabitRepositoryImpl
│   │   └── presentation/         # UI & State
│   │       ├── cubit/            # HabitsCubit
│   │       ├── helpers/          # Translation Helpers
│   │       └── pages/            # TodayPage, CreateHabitPage
│   │
│   └── analytics/
│       ├── domain/               # Analytics logic
│       │   ├── entities/         # DailySummary, Insight
│       │   └── services/         # InsightGenerator
│       ├── presentation/         # Analytics UI
│       │   ├── cubit/            # AnalyticsCubit
│       │   └── widgets/          # Heatmap, Trend Charts
│
└── main.dart
```

### Data Flow

```
UI (Widget) → Cubit → UseCase → Repository (interface) → DataSource → ObjectBox
```

---

## ✅ Features (Phases 1-5)

- **Habit Management** — CRUD for habits with customizable icons, colors, and difficulty.
- **Advanced Scheduling** — Daily habits or "X times per week" (ISO-week compliant).
- **Goal Types** — Binary (Yes/No) or Quantitative (e.g., "500ml water", "10 pages read").
- **Streak Engine** — Sophisticated streak tracking with automatic repairs and milestones.
- **Analytics Dashboard** — Advanced visualization with `fl_chart`:
    - **Completion Trends**: Weekly visualization of performance.
    - **Heatmap Calendar**: Year-view of habit consistency.
    - **Metric Cards**: Tracking "Perfect Days", "Best Performance Day", and "Active Streaks".
- **Smart Insights** — Automated feedback on consistency and performance trends.
- **Arabic UI** — Full RTL and localized content for all features.
- **App Icons** — Custom branded icons for both Android and iOS.

---

## ✨ Design & UX

The app follows modern design principles to provide a premium and tactile experience:
- **Premium Aesthetics** — Vibrant colors, dark mode support, and harmonious palettes generated from seeds.
- **Depth & Dimension** — Multi-layered drop shadows and glassmorphism.
- **Micro-animations** — Subtle, interactive transitions for enhanced engagement.
- **Tactile Feel** — Subtle noise textures and elegant "glow" effects on interactive elements.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | Flutter (Material 3) |
| **State Management** | flutter_bloc (Cubit) |
| **Local Persistence** | ObjectBox |
| **Visualization** | fl_chart (Heatmaps & Trends) |
| **Navigation** | GoRouter |
| **Dependency Injection** | get_it |
| **Localization** | intl |
| **Branding** | flutter_launcher_icons |
| **ID Generation** | uuid |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+

### Installation

```bash
# Clone the repository
git clone https://github.com/ahmedramadan-20/multazim.git
cd multazim

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
| 6 | Gamification (Levels, XP, Rewards) | 🔜 Next |
| 7 | Cloud Sync & Social | 🔜 Planned |

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
