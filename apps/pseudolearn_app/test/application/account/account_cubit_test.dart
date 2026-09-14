import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_cubit.dart';
import 'package:pseudolearn_app/application/account/account_state.dart';
import 'package:pseudolearn_app/domain/model/account/account_deletion_outcome.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/account/auth_outcome.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'dart:async';
import '../../fakes/fake_account_deletion_gateway.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_incoming_link_source.dart';
import '../../fakes/fake_local_account_data_purger.dart';
import '../../fakes/in_memory_document_repository.dart';

void main() {
  group('AccountCubit', () {
    late FakeAuthGateway authGateway;
    late FakeIncomingLinkSource incomingLinks;
    late InMemoryDocumentRepository documentRepository;
    late FakeAccountDeletionGateway deletionGateway;
    late FakeLocalAccountDataPurger purger;
    late AccountCubit cubit;

    const testSession = AccountSession(
      userId: 'user_123',
      email: 'user@example.com',
      displayName: 'Ada',
      provider: AuthMethod.apple,
    );

    setUp(() {
      authGateway = FakeAuthGateway();
      incomingLinks = FakeIncomingLinkSource();
      documentRepository = InMemoryDocumentRepository();
      deletionGateway = FakeAccountDeletionGateway();
      purger = FakeLocalAccountDataPurger();
      cubit = AccountCubit(
        authGateway: authGateway,
        incomingLinks: incomingLinks,
        documentRepository: documentRepository,
        accountDeletionGateway: deletionGateway,
        localAccountDataPurger: purger,
      );
    });

    tearDown(() async {
      await cubit.close();
      authGateway.dispose();
      incomingLinks.dispose();
    });

    test('initial state is AccountUnauthenticated', () {
      expect(cubit.state, isA<AccountUnauthenticated>());
    });

    group('init()', () {
      test('emits AccountAuthenticated when restored session is present', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        expect(cubit.state, equals(const AccountAuthenticated(testSession)));
      });

      test('emits AccountUnauthenticated when restored session is null', () async {
        authGateway.currentSession = null;
        await cubit.init();
        expect(cubit.state, isA<AccountUnauthenticated>());
      });

      test('emits AccountError without throwing when restoreSession throws (§5.5)', () async {
        authGateway.throwOnRestore = true;
        await expectLater(cubit.init(), completes);
        expect(cubit.state, isA<AccountError>());
      });

      test('updates state when sessionChanges emits a new session', () async {
        await cubit.init();
        expect(cubit.state, isA<AccountUnauthenticated>());

        authGateway.emitSession(testSession);
        await pumpEventQueue();

        expect(cubit.state, equals(const AccountAuthenticated(testSession)));
      });
    });

    group('incoming authentication link', () {
      final callback = Uri.parse('pseudolearn://auth-callback?code=abc123');

      test('completes the session when the gateway authenticates the link', () async {
        await cubit.init();
        authGateway.nextLinkOutcome = const Authenticated(testSession);

        incomingLinks.emit(callback);
        await pumpEventQueue();

        expect(cubit.state, equals(const AccountAuthenticated(testSession)));
      });

      test('leaves the state untouched when the gateway does not recognise the link', () async {
        await cubit.init();
        authGateway.nextLinkOutcome = null;
        final stateBeforeLink = cubit.state;

        incomingLinks.emit(Uri.parse('pseudolearn://other'));
        await pumpEventQueue();

        expect(cubit.state, equals(stateBeforeLink));
      });

      test('emits AccountError when the link is rejected', () async {
        await cubit.init();
        authGateway.nextLinkOutcome = const Rejected('otp_expired');

        incomingLinks.emit(callback);
        await pumpEventQueue();

        expect(cubit.state, equals(const AccountError('otp_expired')));
      });

      test('emits AccountError with no_connection when the exchange has no network', () async {
        await cubit.init();
        authGateway.nextLinkOutcome = const NoConnection();

        incomingLinks.emit(callback);
        await pumpEventQueue();

        expect(cubit.state, equals(const AccountError('no_connection')));
      });

      test('catches an unexpected exception raised while completing the link', () async {
        await cubit.init();
        authGateway.throwOnCompleteFromLink = true;

        incomingLinks.emit(callback);
        await pumpEventQueue();

        expect(cubit.state, isA<AccountError>());
      });

      test('does not emit when the cubit closes while the exchange is in flight', () async {
        await cubit.init();
        authGateway.nextLinkOutcome = const Authenticated(testSession);

        incomingLinks.emit(callback);
        await cubit.close();
        await pumpEventQueue();

        expect(cubit.state, isA<AccountUnauthenticated>());
      });

      test('ignores links that arrive before init subscribes', () async {
        incomingLinks.emit(callback);
        await pumpEventQueue();

        expect(cubit.state, isA<AccountUnauthenticated>());
      });
    });

    group('signIn() across all methods and outcomes', () {
      test('Apple success emits AccountAuthenticated', () async {
        authGateway.nextOutcome = const Authenticated(testSession);
        await cubit.signIn(AuthMethod.apple);
        expect(cubit.state, equals(const AccountAuthenticated(testSession)));
      });

      test('Apple cancelled emits AccountUnauthenticated', () async {
        authGateway.nextOutcome = const Cancelled();
        await cubit.signIn(AuthMethod.apple);
        expect(cubit.state, isA<AccountUnauthenticated>());
      });

      test('Apple no connection emits AccountError with no_connection', () async {
        authGateway.nextOutcome = const NoConnection();
        await cubit.signIn(AuthMethod.apple);
        expect(cubit.state, isA<AccountError>());
        expect((cubit.state as AccountError).message, 'no_connection');
      });

      test('Apple rejected emits AccountError with reason', () async {
        authGateway.nextOutcome = const Rejected('authorization_failed');
        await cubit.signIn(AuthMethod.apple);
        expect(cubit.state, equals(const AccountError('authorization_failed')));
      });

      test('Google success emits AccountAuthenticated', () async {
        const googleSession = AccountSession(
          userId: 'user_456',
          email: 'google@example.com',
          displayName: 'Grace',
          provider: AuthMethod.google,
        );
        authGateway.nextOutcome = const Authenticated(googleSession);
        await cubit.signIn(AuthMethod.google);
        expect(cubit.state, equals(const AccountAuthenticated(googleSession)));
      });

      test('Google cancelled emits AccountUnauthenticated', () async {
        authGateway.nextOutcome = const Cancelled();
        await cubit.signIn(AuthMethod.google);
        expect(cubit.state, isA<AccountUnauthenticated>());
      });

      test('Magic link sent emits AccountUnauthenticated with email notice', () async {
        authGateway.nextOutcome = const MagicLinkSent('test@example.com');
        await cubit.signIn(AuthMethod.magicLink, email: 'test@example.com');
        expect(cubit.state, equals(const AccountUnauthenticated(magicLinkSentToEmail: 'test@example.com')));
      });

      test('Magic link rejected emits AccountError', () async {
        authGateway.nextOutcome = const Rejected('invalid_email');
        await cubit.signIn(AuthMethod.magicLink, email: 'bad_email');
        expect(cubit.state, equals(const AccountError('invalid_email')));
      });

      test('Unexpected exception during signIn is caught and mapped to AccountError (§5.5)', () async {
        authGateway.throwOnSignIn = true;
        await expectLater(cubit.signIn(AuthMethod.apple), completes);
        expect(cubit.state, isA<AccountError>());
      });
    });

    group('signOut() and signOut({deleteLocalData: true}) (D7)', () {
      test('signOut transitions to AccountUnauthenticated and preserves local documents', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        expect(cubit.state, isA<AccountAuthenticated>());

        final doc = Document(
          id: 'doc_1',
          title: 'Algoritmo 1',
          content: 'inicio fin',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        await documentRepository.saveDocument(doc);

        await cubit.signOut();

        expect(cubit.state, isA<AccountUnauthenticated>());
        final remainingDocs = await documentRepository.listDocuments();
        expect(remainingDocs.length, 1);
        expect(remainingDocs.first.id, 'doc_1');
      });

      test('signOut(deleteLocalData: true) transitions to AccountUnauthenticated and deletes local documents', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        expect(cubit.state, isA<AccountAuthenticated>());

        final doc1 = Document(
          id: 'doc_1',
          title: 'Algoritmo 1',
          content: 'inicio fin',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final doc2 = Document(
          id: 'doc_2',
          title: 'Algoritmo 2',
          content: 'inicio fin',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
        );
        await documentRepository.saveDocument(doc1);
        await documentRepository.saveDocument(doc2);

        await cubit.signOut(deleteLocalData: true);

        expect(cubit.state, isA<AccountUnauthenticated>());
        final remainingDocs = await documentRepository.listDocuments();
        expect(remainingDocs, isEmpty);
      });

      test('signOut catches unexpected exception and emits AccountError (§5.5)', () async {
        authGateway.throwOnSignOut = true;
        await expectLater(cubit.signOut(), completes);
        expect(cubit.state, isA<AccountError>());
      });
    });

    group('deleteAccount()', () {
      Future<void> signInWithSession() async {
        authGateway.currentSession = testSession;
        await cubit.init();
        expect(cubit.state, isA<AccountAuthenticated>());
      }

      test('server confirmation signs out, purges local data and emits AccountUnauthenticated', () async {
        await signInWithSession();
        final emitted = <AccountState>[];
        final subscription = cubit.stream.listen(emitted.add);

        await cubit.deleteAccount();
        await pumpEventQueue();
        await subscription.cancel();

        expect(emitted.first, equals(const AccountDeletingAccount(testSession)));
        expect(cubit.state, isA<AccountUnauthenticated>());
        expect(authGateway.currentSession, isNull);
        expect(purger.purgeCalls, 1);
        expect(deletionGateway.deleteCalls, 1);
      });

      test('rejected deletion keeps the session and never purges local data', () async {
        await signInWithSession();
        deletionGateway.nextOutcome = const AccountDeletionRejected('apple_revoke_failed');

        await cubit.deleteAccount();

        expect(cubit.state, equals(const AccountDeletionFailed(testSession, 'apple_revoke_failed')));
        expect(authGateway.currentSession, equals(testSession));
        expect(purger.purgeCalls, 0);
      });

      test('missing connection maps to no_connection and never purges local data', () async {
        await signInWithSession();
        deletionGateway.nextOutcome = const AccountDeletionNoConnection();

        await cubit.deleteAccount();

        expect(cubit.state, equals(const AccountDeletionFailed(testSession, 'no_connection')));
        expect(purger.purgeCalls, 0);
      });

      test('cancelled Apple re-authentication returns to the authenticated state', () async {
        await signInWithSession();
        deletionGateway.nextOutcome = const AccountDeletionCancelled();

        await cubit.deleteAccount();

        expect(cubit.state, equals(const AccountAuthenticated(testSession)));
        expect(purger.purgeCalls, 0);
      });

      test('unexpected gateway exception is contained as unexpected_failure', () async {
        await signInWithSession();
        deletionGateway.throwOnDelete = true;

        await expectLater(cubit.deleteAccount(), completes);

        expect(cubit.state, equals(const AccountDeletionFailed(testSession, 'unexpected_failure')));
        expect(purger.purgeCalls, 0);
      });

      test('a failed deletion can be retried until the server confirms', () async {
        await signInWithSession();
        deletionGateway.nextOutcome = const AccountDeletionNoConnection();
        await cubit.deleteAccount();
        deletionGateway.nextOutcome = const AccountDeleted();

        await cubit.deleteAccount();

        expect(cubit.state, isA<AccountUnauthenticated>());
        expect(deletionGateway.deleteCalls, 2);
        expect(purger.purgeCalls, 1);
      });

      test('purge failure after server confirmation emits local_cleanup_failed', () async {
        await signInWithSession();
        purger.throwOnPurge = true;

        await expectLater(cubit.deleteAccount(), completes);

        expect(cubit.state, equals(const AccountError('local_cleanup_failed')));
        expect(authGateway.currentSession, isNull);
      });

      test('a second request while deletion is in flight is ignored', () async {
        await signInWithSession();
        final release = Completer<void>();
        deletionGateway.pendingCompletion = release.future;

        final first = cubit.deleteAccount();
        await pumpEventQueue();
        await cubit.deleteAccount();
        release.complete();
        await first;

        expect(deletionGateway.deleteCalls, 1);
        expect(cubit.state, isA<AccountUnauthenticated>());
      });

      test('session refresh events during deletion do not re-enable the account actions', () async {
        await signInWithSession();
        final release = Completer<void>();
        deletionGateway.pendingCompletion = release.future;

        final pending = cubit.deleteAccount();
        await pumpEventQueue();
        authGateway.emitSession(testSession);
        await pumpEventQueue();

        expect(cubit.state, equals(const AccountDeletingAccount(testSession)));
        release.complete();
        await pending;
      });

      test('does nothing without an authenticated session', () async {
        await cubit.deleteAccount();

        expect(cubit.state, isA<AccountUnauthenticated>());
        expect(deletionGateway.deleteCalls, 0);
        expect(purger.purgeCalls, 0);
      });

      test('does not emit when the cubit closes while the server request is in flight', () async {
        await signInWithSession();
        final release = Completer<void>();
        deletionGateway.pendingCompletion = release.future;

        final pending = cubit.deleteAccount();
        await pumpEventQueue();
        await cubit.close();
        release.complete();

        await expectLater(pending, completes);
        expect(purger.purgeCalls, 0);
      });
    });
  });
}
