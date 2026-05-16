import 'package:flutter_test/flutter_test.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';

void main() {
  // Friday 15 May 2026 (local) — work week Sat 9 … Wed 13, Thu 14.
  final friday = DateTime(2026, 5, 15);

  test('plan day 0 is Saturday of current work week, not today on Friday', () {
    final sat = WorkWeekDates.dateForPlanDayIndex(0, anchor: friday);
    expect(sat.weekday, DateTime.saturday);
    expect(WorkWeekDates.isoDateForPlanDay(0, anchor: friday), '2026-05-09');
    expect(WorkWeekDates.isoDate(friday), '2026-05-15');
  });

  test('plan days Sat–Wed are five distinct dates ending on Wednesday', () {
    final dates = List.generate(
      WorkWeekDates.planDayCount,
      (i) => WorkWeekDates.isoDateForPlanDay(i, anchor: friday),
    );
    expect(dates, [
      '2026-05-09',
      '2026-05-10',
      '2026-05-11',
      '2026-05-12',
      '2026-05-13',
    ]);
    expect(dates.toSet().length, 5);
  });

  test('planned week range on Friday includes Sat–Wed but not Friday', () {
    final range = WorkWeekDates.plannedWeekRange(anchor: friday);
    expect(range.$1, '2026-05-09');
    expect(range.$2, '2026-05-14');

    const planned = [
      '2026-05-09',
      '2026-05-10',
      '2026-05-11',
      '2026-05-12',
      '2026-05-13',
    ];
    for (final d in planned) {
      expect(d.compareTo(range.$1) >= 0 && d.compareTo(range.$2) <= 0, isTrue);
    }
    expect('2026-05-15'.compareTo(range.$2) > 0, isTrue);
  });
}
