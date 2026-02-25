import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_cubit.dart';
import '../widgets/analytics_view.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AnalyticsCubit>()..loadAnalytics(),
      child: const AnalyticsView(),
    );
  }
}
