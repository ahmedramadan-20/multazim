import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'feature_row.dart';
import 'welcome_actions.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── App icon ────────────────────────
              Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 52,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 24),

              // ── App name ────────────────────────
              Text(
                'ملتزم',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'عادات تدوم طويلاً',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const Spacer(flex: 2),

              // ── Feature highlights ──────────────
              const FeatureRow(
                icon: Icons.offline_bolt_rounded,
                color: AppColors.success,
                title: 'بدون إنترنت',
                subtitle: 'كل بياناتك محفوظة محلياً',
              ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              FeatureRow(
                icon: Icons.sync_rounded,
                color: colorScheme.primary,
                title: 'مزامنة اختيارية',
                subtitle: 'لحفظ بياناتك عبر الأجهزة',
              ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              const FeatureRow(
                icon: Icons.bar_chart_rounded,
                color: AppColors.warning,
                title: 'تحليلات ذكية',
                subtitle: 'تتبع تقدمك بدقة',
              ).animate(delay: 700.ms).fadeIn().slideX(begin: 0.1, end: 0),

              const Spacer(flex: 2),

              const WelcomeActions()
                  .animate(delay: 900.ms)
                  .fadeIn()
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),
              Text(
                'تملك بياناتك بالكامل',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 1100.ms).fadeIn(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
