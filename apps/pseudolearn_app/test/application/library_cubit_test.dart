import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/library/library_state.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_identifier_generator.dart';
import '../fakes/in_memory_document_repository.dart';

void main() {
  group('LibraryCubit', () {
    late InMemoryDocumentRepository repo;
    late FakeIdentifierGenerator idGen;
    late FakeClock clock;
    late LibraryCubit cubit;

    setUp(() {
      repo = InMemoryDocumentRepository();
      idGen = FakeIdentifierGenerator(['test-doc-id', 'test-doc-id-2', 'test-doc-id-3']);
      clock = FakeClock(DateTime(2026, 8, 15, 12, 0));
      cubit = LibraryCubit(
        repository: repo,
        idGenerator: idGen,
        clock: clock,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is empty and initial status', () {
      expect(cubit.state.status, LibraryStatus.initial);
      expect(cubit.state.allDocuments, isEmpty);
    });

    test('create, load, and search documents', () async {
      final doc = await cubit.createDocument(
        title: 'Fibonacci',
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(doc, isNotNull);
      expect(doc!.title, 'Fibonacci');
      expect(cubit.state.status, LibraryStatus.success);
      expect(cubit.state.allDocuments.length, 1);
      expect(cubit.state.filteredDocuments.length, 1);

      cubit.searchDocuments('Fibo');
      expect(cubit.state.filteredDocuments.length, 1);

      cubit.searchDocuments('Matrices');
      expect(cubit.state.filteredDocuments, isEmpty);
      expect(cubit.state.isEmptySearchResults, isTrue);

      cubit.searchDocuments('');
      expect(cubit.state.filteredDocuments.length, 1);
    });

    test('createDocument rejects empty title or whitespace', () async {
      final doc = await cubit.createDocument(
        title: '   ',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(doc, isNull);
      expect(cubit.state.allDocuments, isEmpty);
    });

    test('createDocument rejects duplicate title regardless of casing or extra spaces', () async {
      final doc1 = await cubit.createDocument(
        title: 'Algoritmo Uno',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(doc1, isNotNull);

      final docDuplicate = await cubit.createDocument(
        title: '  algoritmo   uno  ',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(docDuplicate, isNull);
      expect(cubit.state.allDocuments.length, 1);
    });

    test('rename and delete document', () async {
      final doc = await cubit.createDocument(
        title: 'Original',
        profileId: SyntaxProfileId.classicSpanish,
      );

      final renameSuccess = await cubit.renameDocument(doc!.id, 'Renombrado');
      expect(renameSuccess, isTrue);
      expect(cubit.state.allDocuments.first.title, 'Renombrado');

      final deleteSuccess = await cubit.deleteDocument(doc.id);
      expect(deleteSuccess, isTrue);
      expect(cubit.state.allDocuments, isEmpty);
      expect(cubit.state.isEmptyLibrary, isTrue);
    });

    test('renameDocument allows keeping own title', () async {
      final doc = await cubit.createDocument(
        title: 'Mi Algoritmo',
        profileId: SyntaxProfileId.classicSpanish,
      );

      final renameOwn = await cubit.renameDocument(doc!.id, '  mi   algoritmo ');
      expect(renameOwn, isTrue);
      expect(cubit.state.allDocuments.first.title, 'mi algoritmo');
    });

    test('renameDocument rejects duplicate title of another document', () async {
      final doc1 = await cubit.createDocument(
        title: 'Doc A',
        profileId: SyntaxProfileId.classicSpanish,
      );
      final doc2 = await cubit.createDocument(
        title: 'Doc B',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(doc1, isNotNull);
      expect(doc2, isNotNull);

      final renameCollision = await cubit.renameDocument(doc2!.id, 'doc a');
      expect(renameCollision, isFalse);
    });
  });
}
