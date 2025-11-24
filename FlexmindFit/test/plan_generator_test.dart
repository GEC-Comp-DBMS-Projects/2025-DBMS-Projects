import 'package:flutter_test/flutter_test.dart';
import 'package:flexmind_fit/services/plan_generator.dart';

void main() {
  test('generate 7-day plan returns 7 days and progressive durations', () {
    final plan = generatePlan('home_workouts', 7);
    expect(plan.length, 7);

    final firstDay = plan.first;
    final lastDay = plan.last;

    // ensure index and title
    expect(firstDay['index'], 1);
    expect(lastDay['index'], 7);

    // check that duration of first exercise is <= last exercise (progressive increase expected)
    final firstDurations = (firstDay['exercises'] as List)
        .map((e) => e['duration'] as int)
        .toList();
    final lastDurations = (lastDay['exercises'] as List)
        .map((e) => e['duration'] as int)
        .toList();

    expect(firstDurations.length, lastDurations.length);
    // at least one exercise should have increased duration
    bool anyIncreased = false;
    for (int i = 0; i < firstDurations.length; i++) {
      if (lastDurations[i] >= firstDurations[i]) anyIncreased = true;
    }
    expect(anyIncreased, true);
  });
}
