class AppRoutes {
  AppRoutes._();

  static const String today = '/';
  static const String analytics = '/analytics';
  static const String createHabit = '/habit/new';
  static const String habitDetail = '/habit/:id';

  // Helper — builds the actual path with the ID filled in
  // Usage: AppRoutes.habitDetailPath('abc123') → '/habit/abc123'
  static String habitDetailPath(String id) => '/habit/$id';
}
