extension DateTimeExtensions on DateTime {
  // Returns this date at 00:00:00
  DateTime get startOfDay => DateTime(year, month, day);

  // Returns this date at 23:59:59.999
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  // Check if two dates are the same calendar day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Get day of week as int (1 = Monday, 7 = Sunday)
  // DateTime.weekday returns 1-7 but Monday = 1
  int get dayOfWeekInt => weekday;

  // For analytics — "15 يناير"
  String toArabicShort() {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '$day ${months[month - 1]}';
  }
}
