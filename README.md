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

> 🚧 **Status:** Phase 1 (Core Habit Loop) is complete. Local-only persistence with ObjectBox. Cloud sync coming in Phase 5.

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
│   └── habits/
│       ├── domain/               # Pure Dart — no framework imports
│       │   ├── entities/         # Habit, HabitEvent
│       │   ├── repositories/     # HabitRepository (abstract)
│       │   └── usecases/         # GetHabits, CreateHabit, CompleteHabit, etc.
│       │
│       ├── data/                 # Framework-dependent implementations
│       │   ├── models/           # HabitModel, HabitEventModel (@Entity)
│       │   ├── datasources/      # ObjectBoxHabitDataSource
│       │   └── repositories/     # HabitRepositoryImpl
│       │
│       └── presentation/         # Flutter UI + state management
│           ├── cubit/            # HabitsCubit + HabitsState
│           ├── pages/            # TodayPage, CreateHabitPage
│           └── widgets/          # HabitCard
│
└── main.dart
```

### Data Flow

```
UI (Widget) → Cubit → UseCase → Repository (interface) → DataSource → ObjectBox
```

---

## ✅ Phase 1 Features

- **Habit CRUD** — Create, read, update, and delete habits
- **Daily tracking** — Tap to complete, long-press for options (edit, skip, delete)
- **Flexible scheduling** — Daily or X times per week
- **Goal types** — Binary (yes/no) or count-based (e.g., 30 mins)
- **Strictness levels** — Low, medium, high
- **Swipe to delete** — With confirmation dialog
- **Shimmer loading** — Animated loading placeholders
- **Error handling** — `LocalException` → `LocalFailure` → `HabitsError` flow
- **Arabic UI** — Full RTL support with Arabic locale

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | Flutter (Material 3) |
| **State Management** | flutter_bloc (Cubit) |
| **Local Persistence** | ObjectBox |
| **Navigation** | GoRouter |
| **Dependency Injection** | get_it |
| **Code Generation** | build_runner + ObjectBox generator |
| **Value Equality** | Equatable |
| **IDs** | uuid |

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

# Generate ObjectBox code (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 🗺️ Roadmap

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Core Habit Loop (CRUD, tracking, ObjectBox) | ✅ Complete |
| 2 | Habit Details & Analytics | 🔜 Planned |
| 3 | Streaks & Gamification | 🔜 Planned |
| 4 | Notifications & Reminders | 🔜 Planned |
| 5 | Cloud Sync (Supabase) | 🔜 Planned |
| 6 | Theme & Settings | 🔜 Planned |

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
