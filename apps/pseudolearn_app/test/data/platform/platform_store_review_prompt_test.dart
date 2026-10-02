import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/in_app_review_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pseudolearn_app/data/platform/platform_store_review_prompt.dart';

final class _FakeInAppReviewPlatform extends InAppReviewPlatform
    with MockPlatformInterfaceMixin {
  bool available = true;
  Object? requestFailure;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requests++;
    final failure = requestFailure;
    if (failure != null) throw failure;
  }
}

void main() {
  late _FakeInAppReviewPlatform platform;

  setUp(() {
    platform = _FakeInAppReviewPlatform();
    InAppReviewPlatform.instance = platform;
  });

  group('PlatformStoreReviewPrompt', () {
    test('requests the native review when the store is available', () async {
      await const PlatformStoreReviewPrompt().request();

      expect(platform.requests, equals(1));
    });

    test('does nothing when the platform has no store review', () async {
      platform.available = false;

      await const PlatformStoreReviewPrompt().request();

      expect(platform.requests, equals(0));
    });

    test('absorbs a missing native plugin', () async {
      platform.requestFailure = MissingPluginException('no implementation');

      await expectLater(const PlatformStoreReviewPrompt().request(), completes);
    });

    test('absorbs a platform error from the store', () async {
      platform.requestFailure = PlatformException(code: 'store-error');

      await expectLater(const PlatformStoreReviewPrompt().request(), completes);
    });
  });
}
