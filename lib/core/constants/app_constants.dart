class AppConstants {
  AppConstants._(); // private constructor — no instantiation

  // App
  static const String appName = 'ملتزم';

  // ObjectBox
  static const String objectBoxDirectory = 'multazim-db';

  // Supabase table names — single source of truth
  static const String habitsTable = 'habits';
  static const String habitEventsTable = 'habit_events';
  static const String streaksTable = 'streaks';

  // Streak defaults per StrictnessLevel
  static const double lowThreshold = 0.75; // 75% over 30 days
  static const int mediumAllowedSkips = 2; // skips per week
  static const int consistencyWindow = 30; // days

  // Analytics
  static const List<int> chartRanges = [7, 30, 90]; // days
}
