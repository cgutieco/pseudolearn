import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/library/use_cases/create_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/delete_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/list_documents.dart';
import 'package:pseudolearn_app/application/library/use_cases/load_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/rename_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/save_document_source.dart';
import 'package:pseudolearn_app/application/library/use_cases/set_execution_arguments.dart';
import 'package:pseudolearn_app/domain/model/documents/document_command_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../../fakes/document_fixtures.dart';
import '../../../fakes/failing_document_repository.dart';
import '../../../fakes/fake_clock.dart';
import '../../../fakes/fake_identifier_generator.dart';
import '../../../fakes/in_memory_document_repository.dart';

DocumentCommandFailure? _failureOf(DocumentCommandResult result) =>
    result is DocumentCommandRejected ? result.failure : null;

void main() {
  final clock = FakeClock(DateTime(2026, 11, 8, 10));
  late InMemoryDocumentRepository repository;

  setUp(() => repository = InMemoryDocumentRepository());

  group('CreateDocument', () {
    CreateDocument create() => CreateDocument(
      repository: repository,
      identifiers: FakeIdentifierGenerator(['new-id']),
      clock: clock,
    );

    test('stores a normalized document with revision one', () async {
      final result = await create()(
        const CreateDocumentCommand(
          title: '  Suma   simple ',
          profileId: SyntaxProfileId.english,
          content: 'x',
          exerciseId: 'route:e1',
        ),
      );
      final document = (result as DocumentCommandSucceeded).document;
      expect(document.id, 'new-id');
      expect(document.title, 'Suma simple');
      expect(document.revision, 1);
      expect(document.exerciseId, 'route:e1');
      expect(repository.documents['new-id'], isNotNull);
    });

    test('rejects an empty title', () async {
      final result = await create()(
        const CreateDocumentCommand(
          title: '   ',
          profileId: SyntaxProfileId.classicSpanish,
        ),
      );
      expect(_failureOf(result), DocumentCommandFailure.titleUnavailable);
    });

    test('rejects a duplicate title ignoring case', () async {
      repository.documents['doc-1'] = documentFixture(title: 'Fibonacci');
      final result = await create()(
        const CreateDocumentCommand(
          title: 'fibonacci',
          profileId: SyntaxProfileId.classicSpanish,
        ),
      );
      expect(_failureOf(result), DocumentCommandFailure.titleUnavailable);
    });

    test('turns a storage error into a value', () async {
      final result = await CreateDocument(
        repository: FailingDocumentRepository(),
        identifiers: FakeIdentifierGenerator(),
        clock: clock,
      )(const CreateDocumentCommand(
        title: 'A',
        profileId: SyntaxProfileId.classicSpanish,
      ));
      expect(_failureOf(result), DocumentCommandFailure.storageFailed);
    });
  });

  group('RenameDocument', () {
    test('renames and keeps the revision', () async {
      repository.documents['doc-1'] = documentFixture();
      final result = await RenameDocument(repository: repository, clock: clock)(
        documentId: 'doc-1',
        title: 'Serie',
      );
      final document = (result as DocumentCommandSucceeded).document;
      expect(document.title, 'Serie');
      expect(document.updatedAt, clock.now());
    });

    test('allows keeping the same title with different case', () async {
      repository.documents['doc-1'] = documentFixture();
      final result = await RenameDocument(repository: repository, clock: clock)(
        documentId: 'doc-1',
        title: 'FIBONACCI',
      );
      expect(result, isA<DocumentCommandSucceeded>());
    });

    test('reports a missing document', () async {
      final result = await RenameDocument(repository: repository, clock: clock)(
        documentId: 'missing',
        title: 'X',
      );
      expect(_failureOf(result), DocumentCommandFailure.notFound);
    });

    test('rejects a title used by another document', () async {
      repository.documents['doc-1'] = documentFixture();
      repository.documents['doc-2'] = documentFixture(id: 'doc-2', title: 'Otro');
      final result = await RenameDocument(repository: repository, clock: clock)(
        documentId: 'doc-1',
        title: 'otro',
      );
      expect(_failureOf(result), DocumentCommandFailure.titleUnavailable);
    });
  });

  group('DeleteDocument, ListDocuments and LoadDocument', () {
    test('delete removes the document and reports storage failures', () async {
      repository.documents['doc-1'] = documentFixture();
      expect(await DeleteDocument(repository: repository)('doc-1'), isTrue);
      expect(repository.documents, isEmpty);
      expect(
        await DeleteDocument(repository: FailingDocumentRepository())('x'),
        isFalse,
      );
    });

    test('list returns an empty library and null on failure', () async {
      expect(await ListDocuments(repository: repository)(), isEmpty);
      expect(
        await ListDocuments(repository: FailingDocumentRepository())(),
        isNull,
      );
    });

    test('load distinguishes found, missing and failing', () async {
      repository.documents['doc-1'] = documentFixture();
      final load = LoadDocument(repository: repository);
      expect(await load('doc-1'), isA<DocumentCommandSucceeded>());
      expect(_failureOf(await load('none')), DocumentCommandFailure.notFound);
      expect(
        _failureOf(await LoadDocument(repository: FailingDocumentRepository())('x')),
        DocumentCommandFailure.storageFailed,
      );
    });
  });

  group('SaveDocumentSource and SetExecutionArguments', () {
    test('saving source increments the revision', () async {
      repository.documents['doc-1'] = documentFixture(revision: 4);
      final result = await SaveDocumentSource(repository: repository, clock: clock)
          .byId(documentId: 'doc-1', sourceCode: 'Escribir 1;');
      final document = (result as DocumentCommandSucceeded).document;
      expect(document.revision, 5);
      expect(document.content, 'Escribir 1;');
    });

    test('saving an unknown id is not found', () async {
      final result = await SaveDocumentSource(repository: repository, clock: clock)
          .byId(documentId: 'none', sourceCode: '');
      expect(_failureOf(result), DocumentCommandFailure.notFound);
    });

    test('arguments are stored, including an empty list', () async {
      repository.documents['doc-1'] = documentFixture();
      final set = SetExecutionArguments(repository: repository, clock: clock);
      await set(documentId: 'doc-1', arguments: ['a b', '']);
      expect(repository.documents['doc-1']!.executionArguments, ['a b', '']);
      await set(documentId: 'doc-1', arguments: const []);
      expect(repository.documents['doc-1']!.executionArguments, isEmpty);
      expect(repository.documents['doc-1']!.revision, 3);
    });

    test('arguments on a failing repository are a storage failure', () async {
      final result = await SetExecutionArguments(
        repository: FailingDocumentRepository(),
        clock: clock,
      )(documentId: 'x', arguments: const []);
      expect(_failureOf(result), DocumentCommandFailure.storageFailed);
    });
  });
}
