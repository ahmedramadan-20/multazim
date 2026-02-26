import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../../features/habits/domain/entities/habit.dart';

/// Manages all local notification scheduling for habit reminders.
///
/// Each habit gets a unique notification ID derived from its UUID.
/// Notifications are daily repeating at the habit's set reminder time.
///
/// Usage:
///   await NotificationService.instance.init();
///   await NotificationService.instance.scheduleHabitReminder(habit);
///   await NotificationService.instance.cancelHabitReminder(habitId);
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─────────────────────────────────────────────────
  // INIT — call once from main() before runApp
  // ─────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database and set to device's actual timezone
    // Without this, tz.local defaults to UTC — notifications fire at wrong time
    tz.initializeTimeZones();
    final TimezoneInfo deviceTimezone =
        await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings, // <-- Now a named parameter
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request Android 13+ notification permission
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    // Explicitly request SCHEDULE_EXACT_ALARM permission for Android 14+
    // Exact alarms are required for notifications to fire when the app is killed/idle
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
  }

  // ─────────────────────────────────────────────────
  // SCHEDULE — called when habit is created or updated
  // Cancels any existing notification first, then reschedules
  // ─────────────────────────────────────────────────

  Future<void> scheduleHabitReminder(Habit habit) async {
    // Always cancel first to avoid duplicate notifications
    await cancelHabitReminder(habit.id);

    // No reminder set — nothing to schedule
    if (habit.reminderTime == null) return;

    // Habit is inactive or has ended — nothing to schedule
    if (!habit.isActive) return;
    if (habit.endDate != null && habit.endDate!.isBefore(DateTime.now()))
      return;

    final notifId = _notifIdFromHabitId(habit.id);
    final reminderTime = habit.reminderTime!;

    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'تذكيرات العادات',
        channelDescription: 'تذكيرات يومية لعاداتك',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
    );

    // zonedSchedule positional API (flutter_local_notifications ≥ 17)
    await _plugin.zonedSchedule(
      id: notifId,
      title: 'حان وقت عادتك! ${habit.icon}',
      body: habit.name,
      scheduledDate: _nextInstanceOfTime(
        reminderTime.hour,
        reminderTime.minute,
      ),
      notificationDetails: notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ─────────────────────────────────────────────────
  // CANCEL — called when habit is deleted or reminder removed
  // ─────────────────────────────────────────────────

  Future<void> cancelHabitReminder(String habitId) async {
    await _plugin.cancel(id: _notifIdFromHabitId(habitId));
  }

  // ─────────────────────────────────────────────────
  // RESCHEDULE ALL — restores notifications after device reboot
  // (Android clears scheduled notifications on reboot)
  // ─────────────────────────────────────────────────

  Future<void> rescheduleAll(List<Habit> habits) async {
    for (final habit in habits) {
      if (habit.reminderTime != null && habit.isActive) {
        await scheduleHabitReminder(habit);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────

  /// Converts a habit UUID string to a stable integer notification ID.
  /// Takes the first 8 hex chars of the UUID and converts to int.
  int _notifIdFromHabitId(String habitId) {
    final hex = habitId.replaceAll('-', '').substring(0, 8);
    return int.parse(hex, radix: 16).abs() % 0x7FFFFFFF;
  }

  /// Returns the next occurrence of the given time.
  /// If the time has already passed today, schedules for tomorrow.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Future: deep link to today page or specific habit
  }
}
