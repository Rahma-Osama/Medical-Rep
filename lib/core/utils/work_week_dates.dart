/// Saturday-based work week used by weekly planning (Sat–Wed) and home KPIs (Sat–Thu).
class WorkWeekDates {
  WorkWeekDates._();

  /// Weekly plan tabs: 0 = Sat … 4 = Wed.
  static const int planDayCount = 5;

  static const List<String> planDayNames = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed'];

  /// Saturday that starts the work week containing [anchor] (local date).
  static DateTime saturdayOfWeekContaining(DateTime anchor) {
    final local = DateTime(anchor.year, anchor.month, anchor.day);
    final daysSinceSaturday = (local.weekday + 1) % 7;
    return local.subtract(Duration(days: daysSinceSaturday));
  }

  /// Calendar date for plan tab [index] (0 = Sat … 4 = Wed) in the week of [anchor].
  static DateTime dateForPlanDayIndex(int index, {DateTime? anchor}) {
    assert(index >= 0 && index < planDayCount);
    return saturdayOfWeekContaining(anchor ?? DateTime.now())
        .add(Duration(days: index));
  }

  static String isoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String isoDateForPlanDay(int index, {DateTime? anchor}) =>
      isoDate(dateForPlanDayIndex(index, anchor: anchor));

  /// Maps [dayName] (Sat–Wed) to the correct `visit_date` for the current work week.
  static String? normalizedVisitDate({String? dayName, String? visitDate}) {
    final index = planDayNames.indexOf(dayName ?? '');
    if (index < 0) return visitDate;
    return isoDateForPlanDay(index);
  }

  static int? planDayIndexForName(String? dayName) {
    final index = planDayNames.indexOf(dayName ?? '');
    return index >= 0 ? index : null;
  }

  /// Inclusive `visit_date` range for the home "This Week" planned count (Sat–Thu).
  static (String start, String end) plannedWeekRange({DateTime? anchor}) {
    final saturday = saturdayOfWeekContaining(anchor ?? DateTime.now());
    final thursday = saturday.add(const Duration(days: 5));
    return (isoDate(saturday), isoDate(thursday));
  }
}
