class AppRoutes {
  AppRoutes._();

  static const String today = '/';
  static const String analytics = '/analytics';
  static const String createHabit = '/habit/new';
  static const String habitDetail = '/habit/:id';
  static const String habitDetailAnalytics = '/habit/:id/analytics';

  // Auth
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String export = '/export';

  // Helpers
  static String habitDetailPath(String id) => '/habit/$id';
  static String habitDetailAnalyticsPath(String id) => '/habit/$id/analytics';
}
