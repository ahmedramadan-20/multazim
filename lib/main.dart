import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DEFERRED TO PHASE 5 — local-only for now
  // await dotenv.load(fileName: '.env');
  // await Supabase.initialize(
  //   url: Env.supabaseUrl,
  //   anonKey: Env.supabaseAnonKey,
  // );

  // Initialize date formatting for Arabic
  await initializeDateFormatting('ar', null);

  // Wire all dependencies
  await initDependencies();

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
