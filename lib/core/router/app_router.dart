import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:multazim/features/analytics/presentation/pages/analytics_page.dart';
import 'package:multazim/features/analytics/presentation/pages/habit_detail_analytics_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/export/presentation/cubit/export_cubit.dart';
import '../../features/export/presentation/pages/export_page.dart';
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
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  void _showSettingsSheet(BuildContext context) {
    final authCubit = sl<AuthCubit>();
    final authState = authCubit.state;
    final colorScheme = Theme.of(context).colorScheme;

    final isGuest = authState is AuthGuest;
    final user = authState is AuthAuthenticated ? authState.user : null;

    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return Padding(
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
                        user.email.isNotEmpty
                            ? user.email[0].toUpperCase()
                            : '?',
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
                      Icons.privacy_tip_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      'سياسة الخصوصية',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      launchUrl(
                        Uri.parse('https://ahmedramadan-20.github.io/multazim-privacy/'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),

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
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // No AppBar — TodayHeader and analytics page handle their own headers
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Floating nav pill ──────────────────
              Expanded(
                child: _FloatingNavPill(
                  selectedIndex: selectedIndex,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  onSettingsTap: () => _showSettingsSheet(context),
                ),
              ),
              const SizedBox(width: 12),

              // ── Gradient FAB ───────────────────────
              // Only show on today tab — analytics doesn't need it
              if (selectedIndex == 0)
                _GradientFAB(
                  onTap: () => context.push(AppRoutes.createHabit),
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// FLOATING NAV PILL
// ─────────────────────────────────────────────────

class _FloatingNavPill extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ColorScheme colorScheme;
  final void Function(int) onTap;
  final VoidCallback onSettingsTap;

  const _FloatingNavPill({
    required this.selectedIndex,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pillBg =
        Theme.of(context).navigationBarTheme.backgroundColor ??
        colorScheme.surfaceContainer;
    final pillBorder = isDark
        ? colorScheme.outline.withValues(alpha: 0.15)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: pillBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            selectedIndex: selectedIndex,
            outlineIcon: Icons.today_outlined,
            solidIcon: Icons.today,
            label: 'اليوم',
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: onTap,
          ),
          _NavItem(
            index: 1,
            selectedIndex: selectedIndex,
            outlineIcon: Icons.bar_chart_outlined,
            solidIcon: Icons.bar_chart,
            label: 'التحليل',
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: onTap,
          ),
          // Settings button as a third nav-style item
          _SettingsItem(
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData outlineIcon;
  final IconData solidIcon;
  final String label;
  final bool isDark;
  final ColorScheme colorScheme;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.outlineIcon,
    required this.solidIcon,
    required this.label,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final navTheme = Theme.of(context).navigationBarTheme;

    final selectedBg = navTheme.indicatorColor ?? colorScheme.primaryContainer;
    final selectedFg = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final unselectedFg = colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutQuint,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? colorScheme.primary : unselectedFg,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutQuint,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 7),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selectedFg,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          Icons.account_circle_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// GRADIENT FAB
// ─────────────────────────────────────────────────

class _GradientFAB extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _GradientFAB({required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Use the app's primary color for the gradient
    final base = colorScheme.primary;
    final light = Color.lerp(base, Colors.white, 0.25) ?? base;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [light, base],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => BlocProvider.value(
        value: sl<HabitsCubit>(),
        child: AppShell(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (context, state) => const TodayPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.analytics,
              builder: (context, state) => const AnalyticsPage(),
            ),
          ],
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
