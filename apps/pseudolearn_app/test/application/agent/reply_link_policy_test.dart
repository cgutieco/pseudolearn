import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/reply_link_policy.dart';
import '../../fakes/fake_external_url_launcher.dart';

void main() {
  group('openableReplyLink', () {
    test('accepts https and http links with a host', () {
      expect(openableReplyLink('https://pseudolearn.app/a?b=1'), Uri.parse('https://pseudolearn.app/a?b=1'));
      expect(openableReplyLink('http://example.com'), Uri.parse('http://example.com'));
    });

    test('is case-insensitive about the scheme and trims the target', () {
      expect(openableReplyLink('  HTTPS://example.com/x  '), isNotNull);
    });

    test('rejects a missing target', () {
      expect(openableReplyLink(null), isNull);
      expect(openableReplyLink(''), isNull);
    });

    test('rejects schemes that could run code or reach other apps', () {
      for (final target in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'mailto:someone@example.com',
        'tel:+123',
        'intent://scan/#Intent;end',
        'pseudolearn://auth-callback?token=x',
        'data:text/html,<b>x</b>',
      ]) {
        expect(openableReplyLink(target), isNull, reason: target);
      }
    });

    test('rejects relative links and links without a host', () {
      expect(openableReplyLink('/conocimiento/especificacion/x'), isNull);
      expect(openableReplyLink('example.com'), isNull);
      expect(openableReplyLink('https://'), isNull);
    });

    test('rejects credentials embedded in the authority', () {
      expect(openableReplyLink('https://user:secret@example.com/'), isNull);
    });

    test('rejects text that is not a URI', () {
      expect(openableReplyLink('http://[::1'), isNull);
    });
  });

  group('ReplyLinkOpener', () {
    test('launches an openable link and reports success', () async {
      final launcher = FakeExternalUrlLauncher();
      final opener = ReplyLinkOpener(launcher);

      expect(await opener.open('https://pseudolearn.app'), isTrue);
      expect(launcher.launchedUrls, [Uri.parse('https://pseudolearn.app')]);
    });

    test('never launches an unsafe or missing target', () async {
      final launcher = FakeExternalUrlLauncher();
      final opener = ReplyLinkOpener(launcher);

      expect(await opener.open('javascript:alert(1)'), isFalse);
      expect(await opener.open(null), isFalse);
      expect(launcher.launchedUrls, isEmpty);
    });

    test('reports a launcher that fails to open the link', () async {
      final launcher = FakeExternalUrlLauncher()..shouldSucceed = false;

      expect(await ReplyLinkOpener(launcher).open('https://pseudolearn.app'), isFalse);
    });

    test('canOpen mirrors the policy', () {
      final opener = ReplyLinkOpener(FakeExternalUrlLauncher());

      expect(opener.canOpen('https://pseudolearn.app'), isTrue);
      expect(opener.canOpen('file:///x'), isFalse);
    });
  });
}
