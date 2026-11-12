import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/library/library_state.dart';
import 'package:pseudolearn_app/domain/model/documents/document_change.dart';
import '../../fakes/document_fixtures.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/in_memory_document_repository.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late InMemoryDocumentRepository repository;
  late LibraryCubit cubit;

  setUp(() {
    repository = InMemoryDocumentRepository(emitsChanges: true);
    cubit = LibraryCubit(
      repository: repository,
      idGenerator: FakeIdentifierGenerator(),
      clock: FakeClock(),
    );
  });

  tearDown(() => cubit.close());

  test('a document written by another client appears without reloading', () async {
    await cubit.loadDocuments();
    expect(cubit.state.allDocuments, isEmpty);
    await repository.saveDocument(documentFixture());
    await _settle();
    expect(cubit.state.allDocuments.single.id, 'doc-1');
  });

  test('a deletion by another client disappears from the list', () async {
    await repository.saveDocument(documentFixture());
    await cubit.loadDocuments();
    await repository.deleteDocument('doc-1');
    await _settle();
    expect(cubit.state.allDocuments, isEmpty);
  });

  test('changes before the first load do not trigger a load', () async {
    repository.announce(const DocumentChange.reindexed());
    await _settle();
    expect(cubit.state.status, LibraryStatus.initial);
  });

  test('changes after closing are ignored', () async {
    await cubit.loadDocuments();
    await cubit.close();
    await repository.saveDocument(documentFixture());
    await _settle();
    expect(cubit.state.allDocuments, isEmpty);
  });
}
