import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:multazim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  await initializeDateFormatting('ar', null);

  await initDependencies();

  // ✅ Check if a session already exists (e.g. user was logged in before)
  // then start listening for future auth changes (token expiry, remote sign-out)
  await sl<AuthCubit>().checkAuthStatus();
  sl<AuthCubit>().listenToAuthChanges();

  runApp(const MultazimApp());
}

class MultazimApp extends StatelessWidget {
  const MultazimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // go_router takes over navigation completely
      routerConfig: appRouter,

      title: AppConstants.appName,

      // Light theme — dark theme ready for Phase 6
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Arabic support
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],

      debugShowCheckedModeBanner: false,
    );
  }
}
