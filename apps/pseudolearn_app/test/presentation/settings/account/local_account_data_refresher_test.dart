import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_cubit.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/composition/app_providers.dart';
import 'package:pseudolearn_app/domain/model/account/account_deletion_outcome.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/ports/local_account_data_purger.dart';
import 'package:pseudolearn_app/presentation/settings/account/local_account_data_refresher.dart';

import '../../../fakes/fake_account_deletion_gateway.dart';
import '../../../fakes/fake_auth_gateway.dart';
import '../../../fakes/in_memory_document_repository.dart';
import '../../../fakes/test_dependencies.dart';

final class _RepositoryClearingPurger implements LocalAccountDataPurger {
  final InMemoryDocumentRepository repository;

  _RepositoryClearingPurger(this.repository);

  @override
  Future<void> purgeAccountData() async {
    for (final document in await repository.listDocuments()) {
      await repository.deleteDocument(document.id);
    }
  }
}

const _session = AccountSession(userId: 'user-1', provider: AuthMethod.apple);

Future<(AccountCubit, LibraryCubit, FakeAccountDeletionGateway)> _pump(WidgetTester tester) async {
  final repository = InMemoryDocumentRepository();
  await repository.saveDocument(Document(
    id: 'hola',
    title: 'Hola',
    content: '',
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: DateTime(2026, 9, 15),
    updatedAt: DateTime(2026, 9, 15),
  ));
  final deletionGateway = FakeAccountDeletionGateway();
  final dependencies = buildTestDependencies(
    repository: repository,
    authGateway: FakeAuthGateway(currentSession: _session),
    accountDeletionGateway: deletionGateway,
    localAccountDataPurger: _RepositoryClearingPurger(repository),
  );
  late BuildContext scopeContext;
  await tester.pumpWidget(MultiBlocProvider(
    providers: buildAppProviders(dependencies),
    child: LocalAccountDataRefresher(
      child: Builder(builder: (context) {
        scopeContext = context;
        return const SizedBox.shrink();
      }),
    ),
  ));
  await tester.pumpAndSettle();
  final library = scopeContext.read<LibraryCubit>();
  await library.loadDocuments();
  return (scopeContext.read<AccountCubit>(), library, deletionGateway);
}

void main() {
  testWidgets('confirmed account deletion reloads the cached library', (tester) async {
    final (account, library, _) = await _pump(tester);
    expect(library.state.allDocuments, hasLength(1));

    await tester.runAsync(account.deleteAccount);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(library.state.allDocuments, isEmpty);
  });

  testWidgets('failed account deletion leaves the library untouched', (tester) async {
    final (account, library, deletionGateway) = await _pump(tester);
    deletionGateway.nextOutcome = const AccountDeletionNoConnection();

    await tester.runAsync(account.deleteAccount);
    await tester.pumpAndSettle();

    expect(library.state.allDocuments, hasLength(1));
  });
}
