import 'package:campus_life_app/core/services/auth_service.dart';
import 'package:campus_life_app/core/services/exam_countdown_service.dart';
import 'package:campus_life_app/core/services/grade_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('auth bound progress providers', () {
    test('成绩当前用户 provider 会跟随登录用户变化', () {
      final fakeCurrentUserIdProvider = StateProvider<String?>((ref) {
        return 'student-a';
      });
      final container = ProviderContainer(
        overrides: [
          progressCurrentUserIdProvider.overrideWith((ref) {
            return ref.watch(fakeCurrentUserIdProvider);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(gradeCurrentUserIdProvider), 'student-a');

      container.read(fakeCurrentUserIdProvider.notifier).state = 'student-b';

      expect(container.read(gradeCurrentUserIdProvider), 'student-b');
    });

    test('考试倒计时当前用户 provider 会跟随登录用户变化', () {
      final fakeCurrentUserIdProvider = StateProvider<String?>((ref) {
        return 'student-a';
      });
      final container = ProviderContainer(
        overrides: [
          progressCurrentUserIdProvider.overrideWith((ref) {
            return ref.watch(fakeCurrentUserIdProvider);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(examCountdownCurrentUserIdProvider), 'student-a');

      container.read(fakeCurrentUserIdProvider.notifier).state = 'student-c';

      expect(container.read(examCountdownCurrentUserIdProvider), 'student-c');
    });
  });
}
