import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/app_links_incoming_link_source.dart';

void main() {
  group('AppLinksIncomingLinkSource', () {
    late StreamController<Uri> platformLinks;

    setUp(() {
      platformLinks = StreamController<Uri>.broadcast();
    });

    tearDown(() async {
      await platformLinks.close();
    });

    test('forwards every link the platform reports', () async {
      final source = AppLinksIncomingLinkSource(links: platformLinks.stream);
      final received = <Uri>[];
      final subscription = source.incomingLinks().listen(received.add);

      platformLinks.add(Uri.parse('pseudolearn://auth-callback?code=first'));
      platformLinks.add(Uri.parse('pseudolearn://auth-callback?code=second'));
      await pumpEventQueue();
      await subscription.cancel();

      expect(received, hasLength(2));
      expect(received.first.queryParameters['code'], 'first');
      expect(received.last.queryParameters['code'], 'second');
    });

    test('forwards a platform failure instead of swallowing it', () async {
      final source = AppLinksIncomingLinkSource(links: platformLinks.stream);
      final errors = <Object>[];
      final subscription =
          source.incomingLinks().listen((_) {}, onError: errors.add);

      platformLinks.addError(StateError('platform channel failure'));
      await pumpEventQueue();
      await subscription.cancel();

      expect(errors, hasLength(1));
    });

    test('emits nothing while the platform reports no link', () async {
      final source = AppLinksIncomingLinkSource(links: platformLinks.stream);
      final received = <Uri>[];
      final subscription = source.incomingLinks().listen(received.add);

      await pumpEventQueue();
      await subscription.cancel();

      expect(received, isEmpty);
    });
  });
}
