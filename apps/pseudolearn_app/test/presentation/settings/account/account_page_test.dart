import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_state.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/presentation/components/dialog/app_dialog.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/account/account_avatar.dart';
import 'package:pseudolearn_app/presentation/settings/account/account_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildTestApp({
  required AccountState state,
  VoidCallback? onSignInApple,
  VoidCallback? onSignInGoogle,
  ValueChanged<String>? onSignInMagicLink,
  VoidCallback? onSignOut,
  VoidCallback? onSignOutAndDelete,
  VoidCallback? onDeleteAccount,
  VoidCallback? onBack,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: AccountView(
      accountState: state,
      onSignInApple: onSignInApple ?? () {},
      onSignInGoogle: onSignInGoogle ?? () {},
      onSignInMagicLink: onSignInMagicLink ?? (_) {},
      onSignOut: onSignOut ?? () {},
      onSignOutAndDeleteLocalData: onSignOutAndDelete ?? () {},
      onDeleteAccount: onDeleteAccount ?? () {},
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  group('AccountView', () {
    const testSession = AccountSession(
      userId: 'usr_789',
      email: 'ada@example.com',
      displayName: 'Ada Lovelace',
      provider: AuthMethod.apple,
    );

    testWidgets('Unauthenticated view renders three login buttons with Apple first', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const AccountUnauthenticated(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cuenta'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Continuar con correo'), findsOneWidget);

      final appleRect = tester.getRect(find.text('Continuar con Apple'));
      final googleRect = tester.getRect(find.text('Continuar con Google'));
      expect(appleRect.top, lessThan(googleRect.top));
    });

    testWidgets('Tapping Apple calls onSignInApple callback', (tester) async {
      var appleCalled = false;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountUnauthenticated(),
        onSignInApple: () => appleCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar con Apple'));
      await tester.pumpAndSettle();

      expect(appleCalled, isTrue);
    });

    testWidgets('Tapping Google calls onSignInGoogle callback', (tester) async {
      var googleCalled = false;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountUnauthenticated(),
        onSignInGoogle: () => googleCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(googleCalled, isTrue);
    });

    testWidgets('Tapping Magic Link opens modal, submit triggers callback', (tester) async {
      String? submittedEmail;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountUnauthenticated(),
        onSignInMagicLink: (email) => submittedEmail = email,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar con correo'));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión con enlace mágico'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'student@example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar enlace'));
      await tester.pumpAndSettle();

      expect(submittedEmail, 'student@example.com');
      expect(find.text('Iniciar sesión con enlace mágico'), findsNothing);
    });

    testWidgets('Authenticated view renders session details, avatar, and three sign out / account actions', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(testSession),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AccountAvatar), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
      expect(find.text('Cerrar sesión y borrar datos de este dispositivo'), findsOneWidget);
      expect(find.text('Eliminar cuenta'), findsOneWidget);
    });

    testWidgets('Tapping Sign Out calls onSignOut directly', (tester) async {
      var signOutCalled = false;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(testSession),
        onSignOut: () => signOutCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(signOutCalled, isTrue);
    });

    testWidgets('Tapping Sign Out & Delete prompts confirmation dialog', (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(testSession),
        onSignOutAndDelete: () => deleteCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar sesión y borrar datos de este dispositivo'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión y borrar datos?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isFalse);

      await tester.tap(find.text('Cerrar sesión y borrar datos de este dispositivo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar datos y salir'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    });

    testWidgets('Tapping Delete Account prompts confirmation dialog', (tester) async {
      var deleteAccountCalled = false;
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(testSession),
        onDeleteAccount: () => deleteAccountCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar cuenta?'), findsOneWidget);
      expect(
        find.text(
          'Tu cuenta y todos los datos asociados se eliminarán permanentemente de los servidores. También se borrarán los documentos de este dispositivo. Esta acción no se puede deshacer.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(deleteAccountCalled, isFalse);

      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(AppDialog),
        matching: find.text('Eliminar cuenta'),
      ));
      await tester.pumpAndSettle();
      expect(deleteAccountCalled, isTrue);
    });

    testWidgets('Error state renders error notice and sign-in options', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const AccountError('no_connection'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sin conexión a internet. Comprueba tu red.'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
    });

    testWidgets('Authenticating state renders indicator', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticating(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Iniciando sesión...'), findsOneWidget);
    });

    testWidgets('Named session shows the address without the private relay notice', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(testSession),
      ));
      await tester.pumpAndSettle();

      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('Correo privado de Apple'), findsNothing);
    });

    testWidgets('Relay session explains the address instead of showing it bare', (tester) async {
      const relaySession = AccountSession(
        userId: 'usr_relay',
        email: '7k5fdm5f2j@privaterelay.appleid.com',
        provider: AuthMethod.apple,
      );

      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(relaySession),
      ));
      await tester.pumpAndSettle();

      expect(find.text('7k5fdm5f2j@privaterelay.appleid.com'), findsOneWidget);
      expect(find.text('Correo privado de Apple'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('Named relay session keeps both the address and the notice', (tester) async {
      const namedRelaySession = AccountSession(
        userId: 'usr_relay',
        email: '7k5fdm5f2j@privaterelay.appleid.com',
        displayName: 'Ada Lovelace',
        provider: AuthMethod.apple,
      );

      await tester.pumpWidget(_buildTestApp(
        state: const AccountAuthenticated(namedRelaySession),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('7k5fdm5f2j@privaterelay.appleid.com'), findsOneWidget);
      expect(find.text('Correo privado de Apple'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
    });
  });
}
