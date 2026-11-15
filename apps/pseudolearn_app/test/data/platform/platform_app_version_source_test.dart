import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pseudolearn_app/data/platform/platform_app_version_source.dart';

void main() {
  group('PlatformAppVersionSource', () {
    test('reads the market version of the installed build', () async {
      PackageInfo.setMockInitialValues(
        appName: 'PseudoLearn',
        packageName: 'com.pseudolearn.app',
        version: '1.1.0',
        buildNumber: '7',
        buildSignature: '',
      );

      expect(await const PlatformAppVersionSource().read(), equals('1.1.0'));
    });
  });
}
