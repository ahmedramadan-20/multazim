import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file first — everything else depends on it
  await dotenv.load(fileName: '.env');
  // Initialize Supabase
  // Replace with your actual URL and anon key from supabase.com → project settings
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

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
