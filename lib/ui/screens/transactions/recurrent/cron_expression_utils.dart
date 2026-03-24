class CronExpressionUtils {
  static String buildWeekly({required int dayOfWeek}) {
    return '* * * * $dayOfWeek';
  }

  static String buildMonthly({required String dayOfMonth}) {
    return '* * $dayOfMonth * *';
  }

  static bool isValidCron(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    return parts.length == 5;
  }
}
