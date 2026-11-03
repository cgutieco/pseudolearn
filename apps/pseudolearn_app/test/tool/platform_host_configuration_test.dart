import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'iOS includes explicit HTTP and localized local network configuration',
    () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('<key>NSAllowsArbitraryLoads</key>\n\t\t<true/>'));
      expect(plist, contains('NSLocalNetworkUsageDescription'));
      for (final language in ['es', 'en']) {
        expect(
          File(
            'ios/Runner/$language.lproj/InfoPlist.strings',
          ).readAsStringSync(),
          contains('NSLocalNetworkUsageDescription'),
        );
      }
      expect(
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
        contains('InfoPlist.strings'),
      );
    },
  );

  test('Windows declares public and local network access', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('internetClient,privateNetworkClientServer'),
    );
  });
}
