import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/settings/app_version_cubit.dart';
import '../../fakes/fake_app_version_source.dart';

void main() {
  group('AppVersionCubit', () {
    test('starts empty before the version is read', () {
      final cubit = AppVersionCubit(source: const FakeAppVersionSource());

      expect(cubit.state, isEmpty);
    });

    test('init publishes the version the source reports', () async {
      final cubit = AppVersionCubit(
        source: const FakeAppVersionSource(version: '2.3.4'),
      );

      await cubit.init();

      expect(cubit.state, equals('2.3.4'));
    });
  });
}
