import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/export/presentation/cubit/export_cubit.dart';
import 'package:multazim/export/presentation/pages/export_page.dart';
import 'package:multazim/features/analytics/presentation/pages/analytics_page.dart';
import 'package:multazim/features/analytics/presentation/pages/habit_detail_analytics_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/presentation/cubit/habit_detail_cubit.dart';
import '../../features/habits/presentation/pages/create_habit_page.dart';
import '../../features/habits/presentation/pages/today_page.dart';
import '../../features/habits/presentation/pages/habit_detail_page.dart';
import '../../features/habits/domain/entities/habit.dart';
import '../di/injection_container.dart';
import 'app_routes.dart';
import 'router_refresh_stream.dart';

// ─────────────────────────────────────────────────
// PAGE TRANSITION
// ─────────────────────────────────────────────────

CustomTransitionPage<T> _buildPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurveTween(curve: Curves.easeOut);
      final slide = Tween(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return FadeTransition(
        opacity: animation.drive(fade),
        child: SlideTransition(position: animation.drive(slide), child: child),
      );
    },
  );
}

// ─────────────────────────────────────────────────
// APP SHELL
// ─────────────────────────────────────────────────

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const List<String> _tabs = [AppRoutes.today, AppRoutes.analytics];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.analytics)) return 1;
    return 0;
  }

  void _showSettingsSheet(BuildContext context) {
    final authCubit = sl<AuthCubit>();
    final authState = authCubit.state;
    final colorScheme = Theme.of(context).colorScheme;

    final isGuest = authState is AuthGuest;
    final user = authState is AuthAuthenticated ? authState.user : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              if (isGuest) ...[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 32,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'وضع الزائر',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'بياناتك محفوظة محلياً على جهازك',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 4),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.cloud_upload_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'إنشاء حساب ومزامنة البيانات',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'احتفظ ببياناتك عبر أجهزتك',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.signUp);
                  },
                ),
              ],

              if (user != null) ...[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName ?? user.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 4),
              ],

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  Icons.upload_file_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'تصدير البيانات',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.export);
                },
              ),

              if (user != null)
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthUnauthenticated) {
                      Navigator.pop(context);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.error,
                              ),
                            )
                          : Icon(
                              Icons.logout_rounded,
                              color: colorScheme.error,
                            ),
                      title: Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: isLoading
                          ? null
                          : () => context.read<AuthCubit>().signOutUser(),
                    );
                  },
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ملتزم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
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

// ─────────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────────

const _publicRoutes = [AppRoutes.welcome, AppRoutes.login, AppRoutes.signUp];

final _authRefreshStream = RouterRefreshStream(sl<AuthCubit>().stream);

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome, // ← was AppRoutes.today
  debugLogDiagnostics: true,
  refreshListenable: _authRefreshStream,
  redirect: (context, state) {
    final authState = sl<AuthCubit>().state;
    final currentPath = state.uri.path;

    // 1. Still initializing — don't redirect, stay on welcome
    if (authState is AuthInitial || authState is AuthLoading) return null;

    final isAuthenticated = authState is AuthAuthenticated;
    final isGuest = authState is AuthGuest;
    final isPublicRoute = _publicRoutes.contains(currentPath);

    // 2. Authenticated — redirect away from public routes
    if (isAuthenticated) {
      if (isPublicRoute) return AppRoutes.today;
      return null;
    }

    // 3. Guest — redirect away from welcome only
    if (isGuest) {
      if (currentPath == AppRoutes.welcome) return AppRoutes.today;
      return null;
    }

    // 4. Unauthenticated — redirect to welcome if not already on public route
    if (!isPublicRoute) return AppRoutes.welcome;

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const WelcomePage(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const SignUpPage(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.export,
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<ExportCubit>(),
          child: const ExportPage(),
        ),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => BlocProvider.value(
        value: sl<HabitsCubit>(),
        child: AppShell(child: child),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.today,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const TodayPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const AnalyticsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.createHabit,
      pageBuilder: (context, state) {
        final habit = state.extra as Habit?;
        return _buildPage(
          context: context,
          state: state,
          child: BlocProvider.value(
            value: sl<HabitsCubit>(),
            child: CreateHabitPage(habit: habit),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.habitDetail,
      pageBuilder: (context, state) {
        final habitId = state.pathParameters['id']!;
        return _buildPage(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<HabitDetailCubit>(),
            child: HabitDetailPage(habitId: habitId),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.habitDetailAnalytics,
      pageBuilder: (context, state) {
        final habitId = state.pathParameters['id']!;
        return _buildPage(
          context: context,
          state: state,
          child: HabitDetailAnalyticsPage(habitId: habitId),
        );
      },
    ),
  ],
);
