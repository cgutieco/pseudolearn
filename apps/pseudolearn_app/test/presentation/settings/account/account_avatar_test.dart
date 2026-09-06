import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/presentation/settings/account/account_avatar.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _hostAvatar(AccountSession session) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: DesignCanvas(child: AccountAvatar(session: session)),
  );
}

AccountSession _session({
  String userId = 'usr_1',
  String? email,
  String? displayName,
  String? photoUrl,
}) {
  return AccountSession(
    userId: userId,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    provider: AuthMethod.apple,
  );
}

void main() {
  group('AccountAvatar', () {
    testWidgets('renders the initials of the display name', (tester) async {
      await tester.pumpWidget(_hostAvatar(
        _session(displayName: 'Ada Lovelace', email: 'ada@example.com'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('AL'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('renders a neutral glyph for an Apple private relay address', (tester) async {
      await tester.pumpWidget(_hostAvatar(
        _session(email: '7k5fdm5f2j@privaterelay.appleid.com'),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('7'), findsNothing);
    });

    testWidgets('renders the remote photo when the session carries one', (tester) async {
      await tester.pumpWidget(_hostAvatar(
        _session(displayName: 'Ada Lovelace', photoUrl: 'https://example.com/ada.png'),
      ));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('falls back to the monogram when the photo fails to load', (tester) async {
      await tester.pumpWidget(_hostAvatar(
        _session(displayName: 'Ada Lovelace', photoUrl: 'https://example.com/ada.png'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('ignores an empty photo url', (tester) async {
      await tester.pumpWidget(_hostAvatar(
        _session(displayName: 'Ada Lovelace', photoUrl: ''),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNothing);
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('gives the same background to the same account identifier', (tester) async {
      await tester.pumpWidget(_hostAvatar(_session(userId: 'usr_789', displayName: 'Ada')));
      await tester.pumpAndSettle();
      final first = tester.widget<Container>(find.byType(Container).first);

      await tester.pumpWidget(_hostAvatar(_session(userId: 'usr_789', displayName: 'Ada')));
      await tester.pumpAndSettle();
      final second = tester.widget<Container>(find.byType(Container).first);

      expect(
        (first.decoration! as BoxDecoration).color,
        (second.decoration! as BoxDecoration).color,
      );
    });
  });
}
