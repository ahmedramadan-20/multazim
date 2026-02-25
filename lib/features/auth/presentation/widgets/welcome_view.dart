import 'package:flutter/material.dart';
import 'feature_row.dart';
import 'welcome_actions.dart';

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
              ),
              const SizedBox(height: 24),

              // ── App name ────────────────────────
              Text(
                'ملتزم',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'بناء عادات يومية تدوم',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // ── Feature highlights ──────────────
              const FeatureRow(
                icon: Icons.offline_bolt_rounded,
                color: Colors.green,
                title: 'يعمل بدون إنترنت',
                subtitle: 'بياناتك محفوظة على جهازك دائماً',
              ),
              const SizedBox(height: 16),
              FeatureRow(
                icon: Icons.sync_rounded,
                color: colorScheme.primary,
                title: 'مزامنة اختيارية',
                subtitle: 'أنشئ حساباً لمزامنة بياناتك عبر أجهزتك',
              ),
              const SizedBox(height: 16),
              const FeatureRow(
                icon: Icons.bar_chart_rounded,
                color: Colors.orange,
                title: 'تحليلات ذكية',
                subtitle: 'رؤى مبنية على سلوكك اليومي الحقيقي',
              ),

              const Spacer(flex: 2),

              const WelcomeActions(),

              const SizedBox(height: 16),
              Text(
                'بياناتك ملكك — لا حاجة لحساب لاستخدام التطبيق',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
