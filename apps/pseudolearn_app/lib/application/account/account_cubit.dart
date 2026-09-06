import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/account/account_session.dart';
import '../../domain/model/account/auth_method.dart';
import '../../domain/model/account/auth_outcome.dart';
import '../../domain/ports/auth_gateway.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/incoming_link_source.dart';
import '../../domain/ports/remote_document_store.dart';
import 'account_state.dart';

final class AccountCubit extends Cubit<AccountState> {
  final AuthGateway _authGateway;
  final IncomingLinkSource _incomingLinks;
  final DocumentRepository? _documentRepository;
  final RemoteDocumentStore? _remoteDocumentStore;
  StreamSubscription<AccountSession?>? _sessionSubscription;
  StreamSubscription<Uri>? _linkSubscription;

  AccountCubit({
    required AuthGateway authGateway,
    required IncomingLinkSource incomingLinks,
    DocumentRepository? documentRepository,
    RemoteDocumentStore? remoteDocumentStore,
  })  : _authGateway = authGateway,
        _incomingLinks = incomingLinks,
        _documentRepository = documentRepository,
        _remoteDocumentStore = remoteDocumentStore,
        super(const AccountUnauthenticated());

  Future<void> init() async {
    _sessionSubscription ??= _authGateway.sessionChanges().listen(_onSession);
    _linkSubscription ??= _incomingLinks.incomingLinks().listen(_onIncomingLink);

    try {
      final session = await _authGateway.restoreSession();
      if (session != null) {
        emit(AccountAuthenticated(session));
      } else {
        emit(const AccountUnauthenticated());
      }
    } catch (error) {
      emit(AccountError(error.toString()));
    }
  }

  Future<void> signIn(AuthMethod method, {String? email}) async {
    emit(const AccountAuthenticating());
    try {
      _emitOutcome(await _authGateway.signIn(method, email: email));
    } catch (error) {
      emit(AccountError(error.toString()));
    }
  }

  Future<void> signOut({bool deleteLocalData = false}) async {
    try {
      await _authGateway.signOut();
      if (deleteLocalData) {
        await _deleteLocalDocuments();
      }
    } catch (error) {
      emit(AccountError(error.toString()));
      return;
    }
    emit(const AccountUnauthenticated());
  }

  Future<void> deleteAccount() async {
    try {
      await _remoteDocumentStore?.deleteAccount();
      await _authGateway.signOut();
      await _deleteLocalDocuments();
    } catch (error) {
      emit(AccountError(error.toString()));
      return;
    }
    emit(const AccountUnauthenticated());
  }

  Future<void> _deleteLocalDocuments() async {
    final repository = _documentRepository;
    if (repository != null) {
      final documents = await repository.listDocuments();
      for (final doc in documents) {
        await repository.deleteDocument(doc.id);
      }
    }
  }

  void _onSession(AccountSession? session) {
    if (session != null) {
      emit(AccountAuthenticated(session));
    } else if (state is AccountAuthenticated) {
      emit(const AccountUnauthenticated());
    }
  }

  Future<void> _onIncomingLink(Uri link) async {
    try {
      final outcome = await _authGateway.completeSignInFromLink(link);
      if (isClosed || outcome == null) return;
      _emitOutcome(outcome);
    } catch (error) {
      if (isClosed) return;
      emit(AccountError(error.toString()));
    }
  }

  void _emitOutcome(AuthOutcome outcome) {
    switch (outcome) {
      case Authenticated(:final session):
        emit(AccountAuthenticated(session));
      case Cancelled():
        emit(const AccountUnauthenticated());
      case NoConnection():
        emit(const AccountError('no_connection'));
      case Rejected(:final reason):
        emit(AccountError(reason));
      case MagicLinkSent(:final email):
        emit(AccountUnauthenticated(magicLinkSentToEmail: email));
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _linkSubscription?.cancel();
    return super.close();
  }
}
