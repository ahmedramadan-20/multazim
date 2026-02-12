import '../../domain/entities/habit.dart';

class HabitTranslationHelper {
  static String categoryName(HabitCategory category) {
    return switch (category) {
      HabitCategory.health => 'صحة',
      HabitCategory.work => 'عمل',
      HabitCategory.mind => 'عقل',
      HabitCategory.social => 'اجتماعي',
      HabitCategory.fitness => 'رياضة',
      HabitCategory.learning => 'تعلم',
      HabitCategory.other => 'أخرى',
    };
  }

  static String strictnessName(StrictnessLevel level) {
    return switch (level) {
      StrictnessLevel.low => 'منخفض',
      StrictnessLevel.medium => 'متوسط',
      StrictnessLevel.high => 'مرتفع',
    };
  }

  static String scheduleTypeName(HabitScheduleType type) {
    return switch (type) {
      HabitScheduleType.daily => 'يومي',
      HabitScheduleType.timesPerWeek => 'مرات في الأسبوع',
      HabitScheduleType.customDays => 'أيام مخصصة',
    };
  }

  static String goalTypeName(HabitGoalType type) {
    return switch (type) {
      HabitGoalType.binary => 'صح/خطأ',
      HabitGoalType.numeric => 'قيمة رقمية',
    };
  }
}
