import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pseudolearn_app/data/platform/platform_external_url_launcher.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

final class _FakeUrlLauncherPlatform extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  String? launchedUrl;
  bool returnResult = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return returnResult;
  }
}

void main() {
  group('PlatformExternalUrlLauncher', () {
    test('delegates launch to platform interface with external application mode',
        () async {
      final fakePlatform = _FakeUrlLauncherPlatform();
      UrlLauncherPlatform.instance = fakePlatform;

      const launcher = PlatformExternalUrlLauncher();
      final target = Uri.parse('https://example.com/oauth');
      final result = await launcher.launchExternalUrl(target);

      expect(result, isTrue);
      expect(fakePlatform.launchedUrl, equals('https://example.com/oauth'));
    });

    test('returns false when platform launch fails', () async {
      final fakePlatform = _FakeUrlLauncherPlatform()..returnResult = false;
      UrlLauncherPlatform.instance = fakePlatform;

      const launcher = PlatformExternalUrlLauncher();
      final result =
          await launcher.launchExternalUrl(Uri.parse('https://example.com'));

      expect(result, isFalse);
    });
  });
}
