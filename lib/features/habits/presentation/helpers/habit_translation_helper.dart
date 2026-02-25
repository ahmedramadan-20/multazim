import '../../domain/entities/habit.dart';

class HabitTranslationHelper {
  static String categoryName(HabitCategory category) {
    return switch (category) {
      HabitCategory.worship => 'عبادة',
      HabitCategory.health => 'صحة',
      HabitCategory.fitness => 'لياقة',
      HabitCategory.mind => 'ذهن',
      HabitCategory.learning => 'تعلم',
      HabitCategory.work => 'عمل',
      HabitCategory.finance => 'مالية',
      HabitCategory.social => 'اجتماعي',
      HabitCategory.selfCare => 'عناية ذاتية',
      HabitCategory.nutrition => 'تغذية',
      HabitCategory.creativity => 'إبداع',
      HabitCategory.other => 'أخرى',
    };
  }

  static String categoryIcon(HabitCategory category) {
    return switch (category) {
      HabitCategory.worship => '🕌',
      HabitCategory.health => '❤️',
      HabitCategory.fitness => '💪',
      HabitCategory.mind => '🧠',
      HabitCategory.learning => '📚',
      HabitCategory.work => '💼',
      HabitCategory.finance => '💰',
      HabitCategory.social => '👥',
      HabitCategory.selfCare => '✨',
      HabitCategory.nutrition => '🥗',
      HabitCategory.creativity => '🎨',
      HabitCategory.other => '📌',
    };
  }

  static String strictnessName(StrictnessLevel level) {
    return switch (level) {
      StrictnessLevel.low => 'مرن',
      StrictnessLevel.medium => 'متوسط',
      StrictnessLevel.high => 'صارم',
    };
  }

  static String strictnessDescription(StrictnessLevel level) {
    return switch (level) {
      StrictnessLevel.low => 'تخطٍّ أحياناً مقبول',
      StrictnessLevel.medium => 'بعض الأيام المفقودة مسموح بها',
      StrictnessLevel.high => 'لا أعذار — كل يوم يحسب',
    };
  }
}
