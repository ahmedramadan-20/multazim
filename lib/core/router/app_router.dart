import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/features/analytics/presentation/pages/analytics_page.dart';
import 'package:multazim/features/analytics/presentation/pages/habit_detail_analytics_page.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/presentation/pages/create_habit_page.dart';
import '../../features/habits/presentation/pages/today_page.dart';
import '../../features/habits/domain/entities/habit.dart';
import '../di/injection_container.dart';
import 'app_routes.dart';

// Temporary placeholder pages — we'll replace these as we build features
class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(name, style: const TextStyle(fontSize: 24))),
    );
  }
}

// The shell wraps all main screens with the bottom navigation bar.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const List<String> _tabs = [AppRoutes.today, AppRoutes.analytics];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.analytics)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'اليوم',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'التحليل',
          ),
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.today,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => BlocProvider.value(
        value: sl<HabitsCubit>(),
        child: AppShell(child: child),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.today,
          builder: (context, state) => const TodayPage(),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          builder: (context, state) => const AnalyticsPage(),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.createHabit,
      builder: (context, state) {
        final habit = state.extra as Habit?;
        return BlocProvider.value(
          value: sl<HabitsCubit>(),
          child: CreateHabitPage(habit: habit),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.habitDetail,
      builder: (context, state) {
        final habitId = state.pathParameters['id']!;
        return _PlaceholderPage('تفاصيل: $habitId');
      },
    ),

    // Analytics Detail
    GoRoute(
      path: AppRoutes.habitDetailAnalytics,
      builder: (context, state) {
        final habitId = state.pathParameters['id']!;
        return HabitDetailAnalyticsPage(habitId: habitId);
      },
    ),
  ],
);
