import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/platform_native_auth_support.dart';

void main() {
  group('PlatformNativeAuthSupport', () {
    test('reports Apple support matching Apple operating systems', () {
      const support = PlatformNativeAuthSupport();
      final expected = Platform.isMacOS || Platform.isIOS;
      expect(support.isAppleSupported, equals(expected));
    });

    test('reports Google support matching mobile and macOS systems', () {
      const support = PlatformNativeAuthSupport();
      final expected =
          Platform.isMacOS || Platform.isIOS || Platform.isAndroid;
      expect(support.isGoogleSupported, equals(expected));
    });
  });
}
