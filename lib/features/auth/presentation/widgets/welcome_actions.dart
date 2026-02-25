import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/auth_cubit.dart';

class WelcomeActions extends StatelessWidget {
  const WelcomeActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.read<AuthCubit>().continueAsGuest(),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('ابدأ بدون حساب', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go(AppRoutes.signUp),
          child: Text(
            'إنشاء حساب جديد',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
