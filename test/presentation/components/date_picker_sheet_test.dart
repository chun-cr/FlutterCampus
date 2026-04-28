import 'package:campus_life_app/presentation/components/date_picker_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DatePickerSheet.normalizeInitialDateTime', () {
    test('早于最小时间时会向上调整到合法的 5 分钟刻度', () {
      final result = DatePickerSheet.normalizeInitialDateTime(
        initialDate: DateTime(2026, 4, 7, 10, 3),
        minDate: DateTime(2026, 4, 7, 10, 3),
        maxDate: DateTime(2026, 4, 7, 12, 0),
        fallbackDate: DateTime(2026, 4, 7, 10, 3),
        minuteInterval: 5,
      );

      expect(result, DateTime(2026, 4, 7, 10, 5));
    });

    test('晚于最大时间时会夹紧到最大时间所在的合法刻度', () {
      final result = DatePickerSheet.normalizeInitialDateTime(
        initialDate: DateTime(2026, 4, 7, 10, 58),
        minDate: DateTime(2026, 4, 7, 10, 0),
        maxDate: DateTime(2026, 4, 7, 10, 47),
        fallbackDate: DateTime(2026, 4, 7, 10, 58),
        minuteInterval: 5,
      );

      expect(result, DateTime(2026, 4, 7, 10, 45));
    });

    test('范围内的时间会保持原有的合法刻度', () {
      final result = DatePickerSheet.normalizeInitialDateTime(
        initialDate: DateTime(2026, 4, 7, 10, 16),
        minDate: DateTime(2026, 4, 7, 10, 0),
        maxDate: DateTime(2026, 4, 7, 11, 0),
        fallbackDate: DateTime(2026, 4, 7, 10, 16),
        minuteInterval: 5,
      );

      expect(result, DateTime(2026, 4, 7, 10, 15));
    });
  });
}
