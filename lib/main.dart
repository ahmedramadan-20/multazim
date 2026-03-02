import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'package:multazim/core/services/connectivity_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await initializeDateFormatting('ar', null);
  await initDependencies();

  // Auth is handled entirely in AuthCubit constructor:
  // - checkAuthStatus() runs automatically
  // - listenToAuthChanges() subscribes automatically
  // Do NOT call them here — that would cause double subscriptions.

  sl<ConnectivityService>().startListening();
  await NotificationService.instance.init();

  // Remove splash BEFORE runApp so it dismisses cleanly
  FlutterNativeSplash.remove();

  runApp(const MultazimApp());
}

class MultazimApp extends StatelessWidget {
  const MultazimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      debugShowCheckedModeBanner: false,
    );
  }
}
