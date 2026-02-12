**HabitOS — Flutter App Blueprint**   |   Personal Behavior Operating System

🧠

**HabitOS**

Personal Behavior Operating System

Flutter App — Full Blueprint & Step-by-Step Workflow

|**Stack**|Flutter + Cubit + Clean Architecture|
| :- | :- |
|**Local DB**|ObjectBox|
|**Backend**|Supabase|
|**DI**|get\_it (manual, no injectable)|
|**Navigation**|go\_router|
|**Architecture**|Feature-based, Clean Architecture|

\

# **1. Product Vision**
HabitOS is not a simple daily checkbox app. It is a **personal behavior operating system** that tracks habits, analyzes behavior patterns, adapts automatically, and motivates action — with minimal input from the user.

### **Core Philosophy**
- **One-tap usage**  — If it takes more than 2 seconds, users quit. Every interaction must be instant.
- **Analytics over aesthetics**  — Charts are not decoration. They change decisions. Data is the product.
- **Flexible habits**  — Life is not always daily. Habits should not be either. Guilt kills retention.

### **What Makes This Different**

|**Feature**|**Typical Apps**|**HabitOS**|
| :- | :- | :- |
|Streaks|Break = reset to 0|Flexible streaks, percentage-based|
|Motivation|Cringe quotes|Behavioral facts and data insights|
|Habit types|Daily only|Daily, X/week, custom schedule|
|Analytics|Basic counts|Heatmaps, trends, day correlation|
|Data model|Static snapshots|Event-based (future-proof)|
|Export|None|CSV, Excel, JSON|

\

# **2. Architecture Decisions**
## **2.1  Why Clean Architecture?**
Clean Architecture separates your app into layers. Each layer has one job. No layer knows about the layers above it. This is what makes the code testable, scalable, and — most importantly for your career — explainable in interviews.

|**💡**|The core rule of Clean Architecture: dependencies point inward. The UI knows about the domain. The domain knows nothing about the UI, database, or network.|
| :-: | :- |

### **The 4 Layers Explained**
**Layer 1 — Domain**  (core of the app, pure Dart, no Flutter, no ObjectBox, no Supabase)

- Contains: Entities (pure data classes), Repository interfaces (abstract), Use Cases (single actions)
- Zero external dependencies. If you deleted Flutter tomorrow, this layer still compiles.
- This is what you own and control 100%. Everything else is a plugin.

**Layer 2 — Data**  (implements the domain's promises)

- Contains: Models (ObjectBox entities), Repository implementations, DataSources (ObjectBox, Supabase)
- This layer translates between your pure domain entities and the external world (database, API).

**Layer 3 — Presentation**  (what the user sees)

- Contains: Cubits (state logic), Pages (screens), Widgets (UI components)
- Cubits call use cases. Use cases call repositories. Repositories call data sources.

**Layer 4 — Core**  (shared utilities)

- Contains: Error handling, Theme, Constants, DI (dependency injection wiring)

## **2.2  Why Cubit over Bloc?**

|**Aspect**|**Bloc**|**Cubit**|
| :- | :- | :- |
|Learning curve|Steeper — Events + States + Bloc|Simpler — just States + methods|
|Boilerplate|High — one file per event|Low — one class, direct methods|
|Testability|Excellent|Excellent (same)|
|CV value|Both are from the same package|Same impression to employers|
|Good for|Very complex event-driven flows|Most real-world apps including this|

|**✅**|Cubit is a subset of Bloc. You can always upgrade a Cubit to full Bloc later if needed. Starting with Cubit is the smart move.|
| :-: | :- |

## **2.3  Why ObjectBox for local storage?**

|**Aspect**|**Hive**|**SQLite / Drift**|**ObjectBox**|
| :- | :- | :- | :- |
|Type|Key-Value NoSQL|Relational SQL|Object-oriented NoSQL|
|Speed|Fast|Moderate|Fastest (native)|
|Dart support|Good|Good|Native Dart-first|
|Queries|Limited|Full SQL|Query builder (type-safe)|
|Relations|Manual|Joins|Native ToOne/ToMany|
|CV rarity|Common|Common|Rare — differentiator|
|Code gen|Yes|Yes|Yes (build\_runner)|

|**⭐**|Very few Flutter developers know ObjectBox deeply. Learning it gives you a genuine edge when discussing "local-first, offline-capable" architecture in interviews.|
| :-: | :- |

## **2.4  Why get\_it without injectable?**
Dependency Injection (DI) means: instead of a class creating its own dependencies, you give them to it from outside. get\_it is a service locator — a global registry where you register and retrieve instances.

|**Aspect**|**get\_it only**|**get\_it + injectable**|
| :- | :- | :- |
|Setup|Manual — you write every line|Auto-generated from annotations|
|Learning value|High — you understand everything|Low — magic hides the wiring|
|Interview answer|Can explain every line|"The generator did it"|
|Transparency|Full visibility|Black box generation|
|Friction|More lines, but readable|Less lines, more setup complexity|

|**📝**|For your learning goals, manual get\_it is the right call. You will understand dependency injection deeply — not just the syntax.|
| :-: | :- |

## **2.5  Why Use Cases? (and why keep them thin)**
A Use Case is a single-action class with one public method. It is the bridge between your Cubit and your Repository. It represents one thing your app can do.

|// ✅ A thin, clean Use Case|
| :- |
|class CompleteHabitUseCase {|
|`  `final HabitRepository repository;|
|`  `CompleteHabitUseCase(this.repository);|
| |
|`  `Future<void> call(String habitId, DateTime completedAt) {|
|`    `return repository.completeHabit(habitId, completedAt);|
|`  `}|
|}|

**Why keep them?**  When an interviewer asks "do you know Clean Architecture?" — without use cases, the honest answer is "kind of." With them, you can explain every layer with confidence. They also prevent your Cubits from becoming bloated as the app grows.

**Rule:**  One Use Case = one action. Keep them thin. They are orchestrators, not business logic containers.

\

# **3. Folder Structure**
The entire app is organized by feature. Each feature is a self-contained world with its own data, domain, and presentation layers. Features do not import from each other — they only communicate through shared domain entities or via the core layer.

## **3.1  Full Structure**

|lib/|
| :- |
|├── core/|
|│   ├── di/|
|│   │   └── injection\_container.dart    # get\_it wiring|
|│   ├── error/|
|│   │   ├── exceptions.dart             # custom exceptions|
|│   │   └── failures.dart               # domain-level failures|
|│   ├── theme/|
|│   │   ├── app\_theme.dart|
|│   │   └── app\_colors.dart|
|│   ├── constants/|
|│   │   └── app\_constants.dart|
|│   └── utils/|
|│       ├── date\_utils.dart|
|│       └── extensions.dart|
|│|
|├── features/|
|│   │|
|│   ├── habits/                         # main feature|
|│   │   ├── data/|
|│   │   │   ├── datasources/|
|│   │   │   │   ├── local/|
|│   │   │   │   │   └── habit\_local\_datasource.dart   # ObjectBox|
|│   │   │   │   └── remote/|
|│   │   │   │       └── habit\_remote\_datasource.dart  # Supabase|
|│   │   │   ├── models/|
|│   │   │   │   ├── habit\_model.dart    # ObjectBox entity|
|│   │   │   │   └── habit\_event\_model.dart|
|│   │   │   └── repositories/|
|│   │   │       └── habit\_repository\_impl.dart|
|│   │   │|
|│   │   ├── domain/|
|│   │   │   ├── entities/|
|│   │   │   │   ├── habit.dart          # pure Dart, no imports|
|│   │   │   │   └── habit\_event.dart|
|│   │   │   ├── repositories/|
|│   │   │   │   └── habit\_repository.dart   # abstract interface|
|│   │   │   └── usecases/|
|│   │   │       ├── get\_habits\_usecase.dart|
|│   │   │       ├── create\_habit\_usecase.dart|
|│   │   │       ├── complete\_habit\_usecase.dart|
|│   │   │       └── skip\_habit\_usecase.dart|
|│   │   │|
|│   │   └── presentation/|
|│   │       ├── cubit/|
|│   │       │   ├── habits\_cubit.dart|
|│   │       │   └── habits\_state.dart|
|│   │       ├── pages/|
|│   │       │   ├── habits\_page.dart|
|│   │       │   └── create\_habit\_page.dart|
|│   │       └── widgets/|
|│   │           ├── habit\_card.dart|
|│   │           └── habit\_progress\_bar.dart|
|│   │|
|│   ├── analytics/|
|│   │   ├── data/|
|│   │   ├── domain/|
|│   │   └── presentation/|
|│   │|
|│   ├── streaks/|
|│   │   ├── data/|
|│   │   ├── domain/|
|│   │   └── presentation/|
|│   │|
|│   └── onboarding/|
|│       ├── data/|
|│       ├── domain/|
|│       └── presentation/|
|│|
|└── main.dart|

## **3.2  Key Rules**
- **domain/ has zero Flutter imports**  — pure Dart only. This makes it independently testable.
- **data/ imports domain/**  — models implement or extend entities.
- **presentation/ imports domain/**  — Cubits use entities and use cases, not models.
- **features never import each other**  — they are independent. Cross-feature data goes through core.
- **core/ is the only shared layer**  — theme, DI, utilities live here.

\

# **4. Data Models**
Everything is **event-based, not state-based**. Instead of storing "habit X has a 14-day streak", we store every individual completion event. This means you can answer any analytics question — including ones you haven't thought of yet.

## **4.1  Domain Entities (pure Dart)**
### **Habit Entity**

|// features/habits/domain/entities/habit.dart|
| :- |
|// ⚠️ NO imports from Flutter, ObjectBox, or Supabase here|
| |
|class Habit {|
|`  `final String id;|
|`  `final String name;|
|`  `final String icon;|
|`  `final String color;|
|`  `final HabitCategory category;|
|`  `final HabitSchedule schedule;|
|`  `final HabitGoal goal;|
|`  `final int difficulty;        // 1–5|
|`  `final DateTime startDate;|
|`  `final DateTime? endDate;     // nullable = no end|
|`  `final bool isActive;|
|`  `final DateTime createdAt;|
| |
|`  `const Habit({|
|`    `required this.id,|
|`    `required this.name,|
|`    `required this.icon,|
|`    `required this.color,|
|`    `required this.category,|
|`    `required this.schedule,|
|`    `required this.goal,|
|`    `required this.difficulty,|
|`    `required this.startDate,|
|`    `this.endDate,|
|`    `this.isActive = true,|
|`    `required this.createdAt,|
|`  `});|
|}|
| |
|enum HabitCategory { health, work, mind, social, fitness, learning, other }|
| |
|enum HabitScheduleType { daily, timesPerWeek, customDays }|
| |
|class HabitSchedule {|
|`  `final HabitScheduleType type;|
|`  `final int? timesPerWeek;            // e.g., 3|
|`  `final List<int>? customDays;        // 1=Mon … 7=Sun|
| |
|`  `const HabitSchedule.daily() :|
|`    `type = HabitScheduleType.daily,|
|`    `timesPerWeek = null,|
|`    `customDays = null;|
| |
|`  `const HabitSchedule.timesPerWeek(int times) :|
|`    `type = HabitScheduleType.timesPerWeek,|
|`    `timesPerWeek = times,|
|`    `customDays = null;|
| |
|`  `const HabitSchedule.custom(List<int> days) :|
|`    `type = HabitScheduleType.customDays,|
|`    `timesPerWeek = null,|
|`    `customDays = days;|
|}|
| |
|class HabitGoal {|
|`  `final HabitGoalType type;|
|`  `final int? targetCount;     // e.g., 30 (minutes), 10 (pages)|
|`  `final String? unit;         // e.g., "mins", "pages"|
| |
|`  `const HabitGoal.binary() :|
|`    `type = HabitGoalType.binary,|
|`    `targetCount = null,|
|`    `unit = null;|
| |
|`  `const HabitGoal.countBased(int count, String unit) :|
|`    `type = HabitGoalType.countBased,|
|`    `targetCount = count,|
|`    `unit = unit;|
|}|
| |
|enum HabitGoalType { binary, countBased }|

### **HabitEvent Entity**
Every single interaction with a habit — completing it, skipping it, failing it — is saved as an event. This is the raw data that powers all analytics.

|// features/habits/domain/entities/habit\_event.dart|
| :- |
| |
|class HabitEvent {|
|`  `final String id;|
|`  `final String habitId;|
|`  `final DateTime date;|
|`  `final HabitEventStatus status;|
|`  `final int? countValue;       // for count-based habits|
|`  `final String? note;          // long-press note|
|`  `final String? failReason;    // why did this fail?|
|`  `final DateTime createdAt;|
|}|
| |
|enum HabitEventStatus {|
|`  `completed,   // ✅ done|
|`  `skipped,     // ⏭  user chose to skip|
|`  `failed,      // ❌ marked as failed|
|`  `missed,      // ⚠️  auto-detected: scheduled but no action|
|}|

### **StreakState Entity**

|// features/streaks/domain/entities/streak\_state.dart|
| :- |
| |
|class StreakState {|
|`  `final String habitId;|
|`  `final int currentStreak;|
|`  `final int longestStreak;|
|`  `final StreakType type;|
|`  `final double completionRate;   // 0.0 – 1.0|
|`  `final DateTime? lastCompletedAt;|
|`  `final bool isAlive;            // streak still active?|
|}|
| |
|enum StreakType {|
|`  `perfect,       // zero misses allowed|
|`  `flexible,      // N skips allowed per period|
|`  `consistency,   // percentage-based (e.g., 80% over 30 days)|
|}|

### **DailySummary Entity**

|// features/analytics/domain/entities/daily\_summary.dart|
| :- |
| |
|class DailySummary {|
|`  `final DateTime date;|
|`  `final int totalScheduled;    // habits due today|
|`  `final int totalCompleted;|
|`  `final int totalSkipped;|
|`  `final int totalFailed;|
|`  `final double completionRate; // completed / scheduled|
| |
|`  `// Computed|
|`  `int get totalMissed => totalScheduled - totalCompleted - totalSkipped - totalFailed;|
|`  `bool get isPerfectDay => totalCompleted == totalScheduled;|
|}|

## **4.2  ObjectBox Models (data layer)**
ObjectBox requires **@Entity** annotations and code generation. Your ObjectBox models live in  features/habits/data/models/ . They are separate from your domain entities — the model is a database representation, the entity is a pure concept.

|// features/habits/data/models/habit\_model.dart|
| :- |
|import 'package:objectbox/objectbox.dart';|
| |
|@Entity()|
|class HabitModel {|
|`  `@Id()|
|`  `int dbId = 0;              // ObjectBox requires int ID|
| |
|`  `@Unique()|
|`  `late String id;            // our UUID|
| |
|`  `late String name;|
|`  `late String icon;|
|`  `late String color;|
|`  `late String categoryName;  // stored as string|
|`  `late String scheduleJson;  // stored as JSON string|
|`  `late String goalJson;|
|`  `late int difficulty;|
|`  `late DateTime startDate;|
|`  `DateTime? endDate;|
|`  `late bool isActive;|
|`  `late DateTime createdAt;|
| |
|`  `// ObjectBox requires default constructor|
|`  `HabitModel();|
| |
|`  `// Convert from domain entity|
|`  `factory HabitModel.fromEntity(Habit habit) {|
|`    `return HabitModel()|
|      ..id = habit.id|
|      ..name = habit.name|
|`      `// ... map all fields|
|`    `;|
|`  `}|
| |
|`  `// Convert to domain entity|
|`  `Habit toEntity() {|
|`    `return Habit(|
|`      `id: id,|
|`      `name: name,|
|`      `// ... map all fields|
|`    `);|
|`  `}|
|}|

|**💡**|The fromEntity() and toEntity() methods are the "translation layer" between your database world and your pure domain world. This separation is what Clean Architecture is all about.|
| :-: | :- |

\

# **5. Dependency Injection with get\_it**
Dependency injection means: classes don't create their own dependencies. They receive them from outside. get\_it is a global service locator — a registry you populate at app start.

## **5.1  Registration Types**

|**Method**|**Creates**|**When to use**|
| :- | :- | :- |
|registerFactory()|New instance every call|Cubits — each screen needs fresh state|
|registerLazySingleton()|One instance, on first access|Repositories, Use Cases, Data Sources|
|registerSingleton()|One instance, immediately at startup|ObjectBox Store, Supabase Client|

## **5.2  The Injection Container**

|// core/di/injection\_container.dart|
| :- |
|import 'package:get\_it/get\_it.dart';|
| |
|final sl = GetIt.instance;  // sl = service locator|
| |
|Future<void> init() async {|
| |
|`  `// ────────────────────────────────────────────|
|`  `// EXTERNAL (create first — others depend on these)|
|`  `// ────────────────────────────────────────────|
|`  `final store = await openObjectBoxStore();|
|`  `sl.registerSingleton<Store>(store);|
|`  `sl.registerSingleton<SupabaseClient>(Supabase.instance.client);|
| |
|`  `// ────────────────────────────────────────────|
|`  `// DATA SOURCES|
|`  `// ────────────────────────────────────────────|
|`  `sl.registerLazySingleton<HabitLocalDataSource>(|
|`    `() => ObjectBoxHabitDataSource(sl()),  // sl() = gets Store|
|`  `);|
|`  `sl.registerLazySingleton<HabitRemoteDataSource>(|
|`    `() => SupabaseHabitDataSource(sl()),   // sl() = gets SupabaseClient|
|`  `);|
| |
|`  `// ────────────────────────────────────────────|
|`  `// REPOSITORIES|
|`  `// ────────────────────────────────────────────|
|`  `sl.registerLazySingleton<HabitRepository>(|
|`    `() => HabitRepositoryImpl(|
|`      `localDataSource: sl(),|
|`      `remoteDataSource: sl(),|
|`    `),|
|`  `);|
| |
|`  `// ────────────────────────────────────────────|
|`  `// USE CASES|
|`  `// ────────────────────────────────────────────|
|`  `sl.registerLazySingleton(() => GetHabitsUseCase(sl()));|
|`  `sl.registerLazySingleton(() => CreateHabitUseCase(sl()));|
|`  `sl.registerLazySingleton(() => CompleteHabitUseCase(sl()));|
|`  `sl.registerLazySingleton(() => SkipHabitUseCase(sl()));|
| |
|`  `// ────────────────────────────────────────────|
|`  `// CUBITS (registerFactory = new instance each time)|
|`  `// ────────────────────────────────────────────|
|`  `sl.registerFactory(() => HabitsCubit(sl()));|
|`  `sl.registerFactory(() => AnalyticsCubit(sl(), sl()));|
|}|

## **5.3  Using get\_it in Widgets**

|// In a widget — provide the Cubit|
| :- |
|BlocProvider(|
|`  `create: (\_) => sl<HabitsCubit>(),  // sl<T>() retrieves the instance|
|`  `child: HabitsPage(),|
|)|
| |
|// sl() without type = inferred from parameter type|
|// sl<Type>() = explicit type retrieval|

\

# **6. Cubit Pattern**
A Cubit has two files: the state file (what data the UI cares about) and the cubit file (the logic that changes that state). The UI listens to state changes and rebuilds automatically.

## **6.1  State File**

|// features/habits/presentation/cubit/habits\_state.dart|
| :- |
| |
|abstract class HabitsState {}|
| |
|class HabitsInitial extends HabitsState {}|
| |
|class HabitsLoading extends HabitsState {}|
| |
|class HabitsLoaded extends HabitsState {|
|`  `final List<Habit> habits;|
|`  `final Map<String, HabitEvent?> todayEvents; // habitId → event|
| |
|`  `HabitsLoaded({|
|`    `required this.habits,|
|`    `required this.todayEvents,|
|`  `});|
|}|
| |
|class HabitsError extends HabitsState {|
|`  `final String message;|
|`  `HabitsError(this.message);|
|}|

## **6.2  Cubit File**

|// features/habits/presentation/cubit/habits\_cubit.dart|
| :- |
| |
|class HabitsCubit extends Cubit<HabitsState> {|
|`  `final GetHabitsUseCase \_getHabits;|
|`  `final CompleteHabitUseCase \_completeHabit;|
|`  `final SkipHabitUseCase \_skipHabit;|
| |
|`  `HabitsCubit({|
|`    `required GetHabitsUseCase getHabits,|
|`    `required CompleteHabitUseCase completeHabit,|
|`    `required SkipHabitUseCase skipHabit,|
|`  `}) :  \_getHabits = getHabits,|
|`        `\_completeHabit = completeHabit,|
|`        `\_skipHabit = skipHabit,|
|`        `super(HabitsInitial());|
| |
|`  `Future<void> loadHabits() async {|
|`    `emit(HabitsLoading());|
|`    `try {|
|`      `final habits = await \_getHabits();|
|`      `emit(HabitsLoaded(habits: habits, todayEvents: {}));|
|`    `} catch (e) {|
|`      `emit(HabitsError(e.toString()));|
|`    `}|
|`  `}|
| |
|`  `Future<void> completeHabit(String habitId) async {|
|`    `await \_completeHabit(habitId, DateTime.now());|
|`    `await loadHabits(); // refresh|
|`  `}|
| |
|`  `Future<void> skipHabit(String habitId) async {|
|`    `await \_skipHabit(habitId, DateTime.now());|
|`    `await loadHabits();|
|`  `}|
|}|

## **6.3  UI consuming the Cubit**

|// In a widget|
| :- |
|BlocBuilder<HabitsCubit, HabitsState>(|
|`  `builder: (context, state) {|
|`    `if (state is HabitsLoading) {|
|`      `return const CircularProgressIndicator();|
|`    `}|
|`    `if (state is HabitsError) {|
|`      `return Text(state.message);|
|`    `}|
|`    `if (state is HabitsLoaded) {|
|`      `return ListView.builder(|
|`        `itemCount: state.habits.length,|
|`        `itemBuilder: (\_, i) => HabitCard(|
|`          `habit: state.habits[i],|
|`          `onComplete: () =>|
|`            `context.read<HabitsCubit>().completeHabit(state.habits[i].id),|
|`          `onSkip: () =>|
|`            `context.read<HabitsCubit>().skipHabit(state.habits[i].id),|
|`        `),|
|`      `);|
|`    `}|
|`    `return const SizedBox();|
|`  `},|
|)|

\

# **7. Streak Engine**
This is where most habit apps fail. A single missed day resetting a 60-day streak is psychologically devastating and the #1 cause of app abandonment. HabitOS has three streak types.

## **7.1  Three Streak Types**
### **Perfect Streak**
- Zero misses allowed. Traditional streak model.
- Best for: habits the user wants to be absolute about (e.g., no alcohol, meditation).

|bool isPerfectStreakAlive(List<HabitEvent> events, HabitSchedule schedule) {|
| :- |
|`  `// Walk backward from today|
|`  `// Any scheduled day without a "completed" event = streak broken|
|`  `return !hasAnyMiss(events, schedule);|
|}|

### **Flexible Streak**
- A configurable number of skips are allowed per week/month.
- Best for: most habits. Removes guilt without removing accountability.

|bool isFlexibleStreakAlive({|
| :- |
|`  `required List<HabitEvent> events,|
|`  `required int allowedSkipsPerWeek,|
|}) {|
|`  `final thisWeekSkips = countSkipsThisWeek(events);|
|`  `return thisWeekSkips <= allowedSkipsPerWeek;|
|}|

### **Consistency Streak**
- Percentage-based. Example: 80% completion over 30 days = streak continues.
- Best for: flexible habits (exercise, reading) where occasional misses are acceptable.

|bool isConsistencyStreakAlive({|
| :- |
|`  `required List<HabitEvent> events,|
|`  `required double threshold,     // e.g., 0.80 = 80%|
|`  `required int windowDays,       // e.g., 30|
|}) {|
|`  `final rate = getCompletionRate(events, windowDays);|
|`  `return rate >= threshold;|
|}|

|**🔥**|The psychological insight: guilt from broken streaks causes more abandonment than the missed habit itself. Flexible streaks increase long-term retention significantly.|
| :-: | :- |

\

# **8. Feature Modules**
## **8.1  Habits Feature (Core)**
- **Today Screen**  — list of today's habits with status indicators
- **One-tap complete**  — single tap marks a habit done
- **Long-press → note**  — add context without breaking the flow
- **Status indicators**  — ✅ Done  ⏭ Skipped  ❌ Failed  ⬜ Pending
- **Count habits**  — progress bar showing 7/30 pages, 15/30 mins

## **8.2  Analytics Feature**
### **Overview Dashboard**
- Today completion percentage
- Active streaks with streak type badge
- Best performing habit this week
- Habit most likely to be skipped (from history)
### **Habit Detail Analytics**
- GitHub-style heatmap calendar (tap day → see notes and events)
- Completion trend line (7 / 30 / 90 / all-time)
- Best day of week histogram
- Miss reasons breakdown (from notes and auto-detection)

## **8.3  Motivation Engine**
No motivational quotes. Instead, **behavioral facts derived from your own data**:

- "You usually fail on Thursdays — schedule lighter habits that day"
- "You're 1 completion away from your longest streak"
- "Reading habit: 3x more successful before 10 AM"
- "You've completed 85% of workouts when you logged them the day before"

|**💡**|These insights require event-based data (Section 4). This is why the data model decisions made now matter for Phase 2 features.|
| :-: | :- |

## **8.4  Export Feature**
- **CSV**  — simple, Excel-compatible
- **Excel (.xlsx)**  — formatted with habit analytics per sheet
- **JSON**  — full event log for power users and data portability
- **Date range filter**  — export last 30 days, custom range, or all-time
- **Per-habit export**  — export a single habit's complete history

\

# **9. Sync Architecture**
The app is offline-first. ObjectBox is the source of truth. Supabase is the mirror. The user experience never depends on a network connection.

## **9.1  Offline-First Strategy**

|// The repository decides the sync strategy|
| :- |
|class HabitRepositoryImpl implements HabitRepository {|
|`  `final HabitLocalDataSource localDataSource;   // ObjectBox|
|`  `final HabitRemoteDataSource remoteDataSource; // Supabase|
| |
|`  `@override|
|`  `Future<List<Habit>> getHabits() async {|
|`    `// 1. ALWAYS return local data immediately (no wait)|
|`    `final local = await localDataSource.getHabits();|
| |
|`    `// 2. Try to sync with remote in background|
|`    `\_syncInBackground();|
| |
|`    `return local; // user never waits for network|
|`  `}|
| |
|`  `@override|
|`  `Future<void> completeHabit(String id, DateTime at) async {|
|`    `// 1. Save locally FIRST — always succeeds|
|`    `await localDataSource.saveEvent(HabitEventModel(...));|
| |
|`    `// 2. Try remote — fail silently, queue for retry|
|`    `try {|
|`      `await remoteDataSource.syncEvent(event);|
|`    `} catch (\_) {|
|`      `await localDataSource.markForSync(event.id);|
|`    `}|
|`  `}|
|}|

## **9.2  Sync Queue**
Any event that fails to sync remotely gets added to a sync queue stored in ObjectBox. When connectivity is restored, the queue is flushed.

|@Entity()|
| :- |
|class SyncQueueItem {|
|`  `@Id() int dbId = 0;|
|`  `late String entityId;|
|`  `late String entityType;   // "habit", "habit\_event", etc.|
|`  `late String action;       // "create", "update", "delete"|
|`  `late String payloadJson;|
|`  `late DateTime createdAt;|
|`  `late bool isSynced;|
|}|

\

# **10. Navigation — go\_router**
Every serious Flutter app needs deep linking — when a notification is tapped, the app must open a specific habit's detail screen directly. go\_router handles this with almost zero extra code. It is the Flutter team's official recommendation and the industry standard.

## **10.1  Why go\_router**

|**Aspect**|**Navigator 2.0 (manual)**|**Custom nav**|**go\_router**|
| :- | :- | :- | :- |
|Learning curve|Very steep|High + you own bugs|Low–medium|
|Deep linking|Complex manual work|Very hard|Built-in, free|
|URL support (web)|Manual implementation|Manual|Built-in|
|CV value|Shows routing knowledge|Risky/niche|Industry standard|
|Maintenance burden|High — you own all edge cases|Highest|Community maintained|

|**💡**|Building custom navigation would be a CV negative — it signals you didn't know go\_router exists, not that you're clever. go\_router is the answer interviewers expect when they ask about routing.|
| :-: | :- |

## **10.2  Router Setup**

|// core/router/app\_router.dart|
| :- |
|import 'package:go\_router/go\_router.dart';|
| |
|final appRouter = GoRouter(|
|`  `initialLocation: AppRoutes.today,|
|`  `routes: [|
| |
|`    `// ShellRoute = bottom nav bar wrapper|
|`    `// All routes inside share the same AppShell (nav bar stays visible)|
|`    `ShellRoute(|
|`      `builder: (context, state, child) => AppShell(child: child),|
|`      `routes: [|
|`        `GoRoute(|
|`          `path: AppRoutes.today,|
|`          `builder: (context, state) => const TodayPage(),|
|`        `),|
|`        `GoRoute(|
|`          `path: AppRoutes.analytics,|
|`          `builder: (context, state) => const AnalyticsPage(),|
|`        `),|
|`      `],|
|`    `),|
| |
|`    `// Habit detail — supports deep linking from push notifications|
|`    `// /habit/abc123 → opens HabitDetailPage with habitId = "abc123"|
|`    `GoRoute(|
|`      `path: AppRoutes.habitDetail,|
|`      `builder: (context, state) {|
|`        `final habitId = state.pathParameters['id']!;|
|`        `return HabitDetailPage(habitId: habitId);|
|`      `},|
|`    `),|
| |
|`    `GoRoute(|
|`      `path: AppRoutes.createHabit,|
|`      `builder: (context, state) => const CreateHabitPage(),|
|`    `),|
|`  `],|
|);|

## **10.3  Route Constants**

|// core/router/app\_routes.dart|
| :- |
|class AppRoutes {|
|`  `static const today       = '/';|
|`  `static const analytics   = '/analytics';|
|`  `static const habitDetail = '/habit/:id';  // :id = dynamic segment|
|`  `static const createHabit = '/habit/new';|
|}|
| |
|// Usage in widgets|
|context.push('/habit/${habit.id}');   // push — has back button|
|context.go(AppRoutes.today);             // replace — no back button|
|context.pop();                           // go back|

\

# **11. Product Refinements**
These three refinements do not change the architecture — they sharpen the user experience and enforce important boundaries. Each one is small in code but significant in product quality and long-term maintainability.

## **Refinement 1 — Strictness Levels (not streak types in UI)**
Internally the streak engine has three powerful types: **perfect**, **flexible**, and **consistency**. But the user should never see those words. Cognitive load kills habit formation. Instead, the user picks a **strictness level** per habit, and the system maps it to the correct engine automatically.

|**User sees**|**Engine uses internally**|**Rule applied**|
| :- | :- | :- |
|🟢  Low|Consistency streak|75% completion over 30 days = alive|
|🟡  Medium|Flexible streak|2 skips per week allowed|
|🔴  High|Perfect streak|Zero misses — no exceptions|

|**🔪**|The user never sees "consistency streak" or "flexible streak". They see Low / Medium / High. The domain layer is still fully powered — nothing is removed, only abstracted in the UI layer.|
| :-: | :- |

### **Implementation**

|// features/habits/domain/entities/habit.dart|
| :- |
| |
|// What the USER chooses — simple, clear|
|enum StrictnessLevel { low, medium, high }|
| |
|class Habit {|
|`  `// ... all existing fields|
|`  `final StrictnessLevel strictness;  // replaces direct StreakType exposure|
|}|
| |
|// features/streaks/domain/services/streak\_mapper.dart|
|// Single responsibility: map user choice → internal engine config|
|class StreakMapper {|
|`  `static StreakType toStreakType(StrictnessLevel level) {|
|`    `return switch (level) {|
|`      `StrictnessLevel.low    => StreakType.consistency,|
|`      `StrictnessLevel.medium => StreakType.flexible,|
|`      `StrictnessLevel.high   => StreakType.perfect,|
|`    `};|
|`  `}|
| |
|`  `static StreakConfig toConfig(StrictnessLevel level) {|
|`    `return switch (level) {|
|`      `StrictnessLevel.low    => StreakConfig.consistency(threshold: 0.75, windowDays: 30),|
|`      `StrictnessLevel.medium => StreakConfig.flexible(allowedSkipsPerWeek: 2),|
|`      `StrictnessLevel.high   => StreakConfig.perfect(),|
|`    `};|
|`  `}|
|}|

**Per-habit, not global:**  Strictness lives on the Habit entity and is set once during creation. A user can have High for meditation and Low for exercise. Never make this a global app setting.

## **Refinement 2 — Analytics Feature Boundary**
**The rule:**  Habits feature owns all writes. Analytics feature is permanently read-only. No analytics logic ever enters a HabitsCubit. No write method ever appears in AnalyticsRepository. This is a discipline rule enforced by structure.

|**HabitsCubit + HabitsRepository**|**AnalyticsCubit + AnalyticsRepository**|
| :- | :- |
|createHabit()|getCompletionRate(range)|
|completeHabit()|getHeatmapData(habitId)|
|skipHabit()|getBestDayOfWeek(habitId)|
|deleteHabit()|getStreakHistory(habitId)|
|✅ Reads + writes habits & events|🚫 Zero write methods — ever, by design|

|// ✅ CORRECT — AnalyticsRepository is read-only by structure|
| :- |
|abstract class AnalyticsRepository {|
|`  `Future<List<DailySummary>> getSummaries(DateRange range);|
|`  `Future<Map<DateTime, double>> getHeatmapData(String habitId);|
|`  `Future<Map<int, double>> getDayOfWeekStats(String habitId);|
|`  `// ← Zero create / update / delete methods. Ever.|
|}|
| |
|// ❌ WRONG — analytics logic leaking into habits feature|
|Future<void> completeHabit(String id) async {|
|`  `await \_completeHabit(id);|
|`  `final rate = await \_analyticsRepo.getRate(); // ← DO NOT DO THIS|
|`  `emit(HabitsLoaded(completionRate: rate));     // ← wrong place|
|}|

|**📏**|If you're inside a HabitsCubit file and feel the urge to call an analytics method — stop. That insight belongs in the AnalyticsCubit, reading from AnalyticsRepository independently.|
| :-: | :- |

## **Refinement 3 — AI Engine: Design Now, Ship Later**
The AI Insights engine is Phase 5. Do not write a single line of AI code until Phase 3 analytics are live and you have real event data to study. Most "AI features" in apps fail because the model is built before the data exists.

|**Phase**|**Action**|**Reason**|
| :- | :- | :- |
|0–2|Store every event faithfully — completions, skips, misses, notes|Raw material. Nothing else matters yet.|
|3|Ship analytics. Study the data manually yourself.|Discover real patterns before automating them.|
|4|Write rule-based insights (no ML)|"You miss on Thursdays" needs data, not AI.|
|5+|Add ML only where rules break down|When patterns are too complex for explicit rules.|

|// Phase 4 — pure logic, zero ML, full value|
| :- |
|class InsightGenerator {|
|`  `List<Insight> generate(List<HabitEvent> events, StreakState streak) {|
|`    `final insights = <Insight>[];|
| |
|`    `// Rule: worst day of week|
|`    `final worstDay = \_findWorstDayOfWeek(events);|
|`    `if (worstDay != null) {|
|`      `insights.add(Insight.warning('You miss most on ${worstDay.name}s'));|
|`    `}|
| |
|`    `// Rule: one away from best streak|
|`    `if (streak.currentStreak == streak.longestStreak - 1) {|
|`      `insights.add(Insight.milestone('One more = your longest streak ever'));|
|`    `}|
| |
|`    `return insights;|
|`  `}|
|}|
| |
|// Phase 5 — swap the implementation, keep the interface|
|// List<HabitEvent> in → List<Insight> out  (interface never changes)|
|// The event-based data model already supports this — no schema changes needed|

|**⭐**|The event-based data model from Section 4 is already AI-ready. When Phase 5 comes, you feed the same HabitEvent list into an ML model. The architecture never changes — only InsightGenerator's implementation.|
| :-: | :- |

\

# **12. Build Phases — Step by Step**
Each phase builds on the previous. Never skip a phase. Each one is independently demonstrable in your portfolio.

|<p>Phase</p><p>**0**</p>|<p>**Foundation**</p><p>Project setup, folder structure, dependencies, ObjectBox setup, DI wiring</p>|
| :-: | :- |

1. Create Flutter project: flutter create habit\_os --org com.yourname
1. Set up folder structure (Section 3)
1. Add dependencies to pubspec.yaml
1. Set up ObjectBox (run build\_runner for code generation)
1. Set up Supabase project and add credentials
1. Wire get\_it injection container (Section 5)
1. Set up go\_router with AppRoutes and AppShell (Section 10)
1. Set up app theme and colors

|<p>Phase</p><p>**1**</p>|<p>**Core Habit Loop**</p><p>Create habit, view today's habits, one-tap complete — fully functional offline</p>|
| :-: | :- |

1. Build Habit domain entity (Section 4.1)
1. Build HabitEvent domain entity
1. Build abstract HabitRepository interface
1. Build ObjectBox HabitModel with fromEntity/toEntity
1. Build HabitLocalDataSource (ObjectBox CRUD)
1. Build HabitRepositoryImpl (local only for now)
1. Build use cases: GetHabits, CreateHabit, CompleteHabit, SkipHabit
1. Build HabitsCubit and HabitsState
1. Build Today Screen UI
1. Build HabitCard widget with one-tap and long-press

|<p>Phase</p><p>**2**</p>|<p>**Streak Engine**</p><p>StrictnessLevel, StreakMapper, all three streak types, streak display</p>|
| :-: | :- |

1. Build StreakState domain entity
1. Build StrictnessLevel enum and StreakMapper service
1. Build StreakCalculationService (pure Dart logic)
1. Add StrictnessLevel to Habit entity and model (replaces direct StreakType)
1. Implement perfect streak calculation
1. Implement flexible streak calculation
1. Implement consistency streak calculation
1. Wire StreakCubit and state
1. Add streak + strictness display to Today Screen and Habit cards

|<p>Phase</p><p>**3**</p>|<p>**Analytics Engine**</p><p>Heatmap, trend charts, completion stats, day-of-week analysis</p>|
| :-: | :- |

1. Build DailySummary entity
1. Build analytics queries on ObjectBox event data
1. Build Overview Dashboard screen
1. Implement GitHub-style heatmap calendar
1. Implement completion trend line chart
1. Implement day-of-week histogram
1. Build Habit Detail Analytics screen

|<p>Phase</p><p>**4**</p>|<p>**Motivation Engine**</p><p>Behavioral insight generation, smart notifications</p>|
| :-: | :- |

1. Build InsightGenerator service
1. Implement day-of-week failure pattern detection
1. Implement streak proximity alerts ("1 away from best")
1. Implement time-of-day correlation (if time is tracked)
1. Add insight cards to dashboard

|<p>Phase</p><p>**5**</p>|<p>**Cloud Sync**</p><p>Supabase auth, remote data source, sync queue, multi-device</p>|
| :-: | :- |

1. Set up Supabase auth (email or Google)
1. Create Supabase database schema (mirrors ObjectBox models)
1. Build SupabaseHabitDataSource
1. Update HabitRepositoryImpl to use both sources
1. Implement sync queue (Section 9.2)
1. Implement background sync on connectivity restore
1. Test multi-device sync scenario

|<p>Phase</p><p>**6**</p>|<p>**Export + Polish**</p><p>CSV/Excel/JSON export, onboarding, app store ready</p>|
| :-: | :- |

1. Build export service (CSV, Excel, JSON)
1. Build export UI with date range selection
1. Build onboarding flow
1. Polish animations and micro-interactions
1. Add app icon and splash screen
1. Write tests for domain layer and use cases
1. Prepare portfolio screenshots and README

\

# **13. Dependencies (pubspec.yaml)**

|dependencies:|
| :- |
|`  `flutter:|
|`    `sdk: flutter|
| |
|`  `# Navigation|
|`  `go\_router: ^13.0.0|
| |
|`  `# State Management|
|`  `flutter\_bloc: ^8.1.3|
| |
|`  `# Dependency Injection|
|`  `get\_it: ^7.6.4|
| |
|`  `# Local Database|
|`  `objectbox: ^2.3.1|
|`  `objectbox\_flutter\_libs: any|
| |
|`  `# Backend / Sync|
|`  `supabase\_flutter: ^2.0.0|
| |
|`  `# Unique IDs|
|`  `uuid: ^4.2.1|
| |
|`  `# Charts & Analytics|
|`  `fl\_chart: ^0.65.0|
| |
|`  `# Date utilities|
|`  `intl: ^0.18.1|
| |
|`  `# Connectivity|
|`  `connectivity\_plus: ^5.0.2|
| |
|`  `# Export|
|`  `csv: ^6.0.0|
|`  `excel: ^4.0.0|
| |
|dev\_dependencies:|
|`  `flutter\_test:|
|`    `sdk: flutter|
| |
|`  `# ObjectBox code generation|
|`  `build\_runner: ^2.4.7|
|`  `objectbox\_generator: ^2.3.1|

## **ObjectBox Code Generation**
After adding ObjectBox entities (Section 4.2), you must run code generation. This creates  objectbox.g.dart  — never edit this file manually.

|# Run once after adding/changing @Entity classes|
| :- |
|flutter pub run build\_runner build --delete-conflicting-outputs|
| |
|# Or watch mode during development|
|flutter pub run build\_runner watch --delete-conflicting-outputs|

\

# **14. CV & Interview Talking Points**
You will be asked to explain your architecture. Here are the questions you'll get and how to answer them confidently.

## **Architecture Questions**
### **"Explain Clean Architecture in your project"**
"My app has three main layers. The **domain layer** contains pure Dart classes — entities, repository interfaces, and use cases. It has zero external dependencies. The **data layer** implements those interfaces using ObjectBox locally and Supabase remotely. The **presentation layer** uses Cubit for state management and only talks to use cases — never directly to the database. Dependencies always point inward toward the domain."

### **"Why ObjectBox over Hive or SQLite?"**
"ObjectBox is an object-oriented, Dart-native database. It's significantly faster than SQLite for the read-heavy workload of an analytics app. It also has native **ToOne and ToMany** relations which map naturally to the habit-event relationship. Most importantly, it generates type-safe query builders — you get compile-time errors for bad queries instead of runtime failures."

### **"How does your offline sync work?"**
"The app is offline-first. ObjectBox is the source of truth. Every write goes to the local database immediately — no network wait. A sync queue stores any events that failed to reach Supabase. When connectivity is restored, the queue is flushed. The user never experiences a loading state for basic operations."

### **"Why Cubit instead of full Bloc?"**
"Cubit is a simplified Bloc — same package, same testing approach, but without the Events layer. For this app, the state transitions are straightforward: loading, loaded, error. Full Bloc would add boilerplate without benefit. If I needed complex event transformation or debouncing, I would upgrade specific cubits to full Bloc."

## **Data Questions**
### **"Why event-based data instead of storing state?"**
"Storing state like 'current streak = 14' answers exactly one question. Storing events — every completion, skip, and miss — answers any question: streak calculation, day-of-week patterns, time-of-day correlation, miss reason analysis. Events are immutable facts. State is derived. The event log enables all future analytics including AI-powered insights without any schema changes."

## **Portfolio Differentiators**
- **ObjectBox knowledge**  — rare among Flutter developers, shows depth
- **Event-based data model**  — shows you think about future requirements
- **Offline-first architecture**  — shows you understand real-world constraints
- **Flexible streak engine**  — shows product thinking, not just technical execution
- **Behavioral analytics**  — shows you understand why users use the product

\

# **15. Quick Reference**
## **Data Flow (read)**

|UI Widget|
| :- |
|`  `→ context.read<HabitsCubit>().loadHabits()|
|`     `→ GetHabitsUseCase.call()|
|`        `→ HabitRepository.getHabits()   ← abstract|
|`           `→ HabitRepositoryImpl.getHabits()|
|`              `→ HabitLocalDataSource.getHabits()   ← ObjectBox|
|`                 `→ returns List<HabitModel>|
|`                    `→ .map((m) => m.toEntity())   ← convert|
|`                       `→ returns List<Habit>   ← pure domain|
|`  `→ emit(HabitsLoaded(habits: habits))|
|`     `→ BlocBuilder rebuilds UI|

## **Data Flow (write)**

|User taps "Complete" on habit card|
| :- |
|`  `→ context.read<HabitsCubit>().completeHabit(habitId)|
|`     `→ CompleteHabitUseCase.call(habitId, DateTime.now())|
|`        `→ HabitRepositoryImpl.completeHabit()|
|`           `→ localDataSource.saveEvent(event)   ← ObjectBox (instant)|
|`           `→ remoteDataSource.syncEvent(event)  ← Supabase (may fail)|
|`              `→ if fails: queue for retry|
|`     `→ loadHabits() to refresh UI|

## **File Naming Convention**

|**Type**|**Naming**|**Example**|
| :- | :- | :- |
|Entity|noun.dart|habit.dart|
|Model|noun\_model.dart|habit\_model.dart|
|Repository (abstract)|noun\_repository.dart|habit\_repository.dart|
|Repository (impl)|noun\_repository\_impl.dart|habit\_repository\_impl.dart|
|DataSource (abstract)|noun\_datasource.dart|habit\_local\_datasource.dart|
|DataSource (impl)|platform\_noun\_datasource.dart|objectbox\_habit\_datasource.dart|
|UseCase|verb\_noun\_usecase.dart|complete\_habit\_usecase.dart|
|Cubit|noun\_cubit.dart|habits\_cubit.dart|
|State|noun\_state.dart|habits\_state.dart|
|Page|noun\_page.dart|habits\_page.dart|
|Widget|noun\_widget.dart|habit\_card.dart|


**HabitOS Blueprint — End of Document**

Build it phase by phase. Ship Phase 0–2 first. The rest follows.
Page  of 
