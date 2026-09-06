import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_cubit.dart';
import 'package:pseudolearn_app/application/account/account_state.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/account/auth_outcome.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_incoming_link_source.dart';
import '../../fakes/fake_remote_document_store.dart';
import '../../fakes/in_memory_document_repository.dart';

void main() {
  group('AccountCubit', () {
    late FakeAuthGateway authGateway;
    late FakeIncomingLinkSource incomingLinks;
    late InMemoryDocumentRepository documentRepository;
    late FakeRemoteDocumentStore remoteDocumentStore;
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
      remoteDocumentStore = FakeRemoteDocumentStore();
      cubit = AccountCubit(
        authGateway: authGateway,
        incomingLinks: incomingLinks,
        documentRepository: documentRepository,
        remoteDocumentStore: remoteDocumentStore,
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
      test('deletes remote data, signs out, purges local documents and emits AccountUnauthenticated', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        expect(cubit.state, isA<AccountAuthenticated>());

        final doc = Document(
          id: 'doc_local',
          title: 'Local Doc',
          content: 'inicio fin',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        await documentRepository.saveDocument(doc);

        await cubit.deleteAccount();

        expect(cubit.state, isA<AccountUnauthenticated>());
        expect(authGateway.currentSession, isNull);
        final remainingDocs = await documentRepository.listDocuments();
        expect(remainingDocs, isEmpty);
      });

      test('catches error when remoteDocumentStore throws and emits AccountError', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        remoteDocumentStore.throwOnDeleteAccount = true;

        await expectLater(cubit.deleteAccount(), completes);
        expect(cubit.state, isA<AccountError>());
      });

      test('catches error when authGateway throws during deleteAccount and emits AccountError', () async {
        authGateway.currentSession = testSession;
        await cubit.init();
        authGateway.throwOnSignOut = true;

        await expectLater(cubit.deleteAccount(), completes);
        expect(cubit.state, isA<AccountError>());
      });
    });
  });
}
