import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/tools/document_editing_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/document_reading_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/document_writing_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/library/use_cases/create_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/delete_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/list_documents.dart';
import 'package:pseudolearn_app/application/library/use_cases/load_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/rename_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/save_document_source.dart';
import 'package:pseudolearn_app/application/library/use_cases/set_execution_arguments.dart';
import 'package:pseudolearn_app/application/program/use_cases/check_program.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/document_fixtures.dart';
import '../../../fakes/fake_clock.dart';
import '../../../fakes/fake_identifier_generator.dart';
import '../../../fakes/in_memory_document_repository.dart';
import '../../../fakes/native_test_engine.dart';

const String _source = 'Algoritmo P\n  Escribir 1;\nFinAlgoritmo\n';

void main() {
  late InMemoryDocumentRepository repository;
  late DocumentSourceWriter writer;
  final clock = FakeClock(DateTime.utc(2026, 11, 8));

  setUp(() {
    repository = InMemoryDocumentRepository()..documents['doc-1'] = documentFixture(content: _source);
    writer = DocumentSourceWriter(
      load: LoadDocument(repository: repository),
      save: SaveDocumentSource(repository: repository, clock: clock),
      check: CheckProgram(analyzer: nativeTestEngine.analyzer),
      language: () => UiLanguageId.spanish,
    );
  });

  test('list and get return the library and one document', () async {
    final listed = await ListDocumentsTool(ListDocuments(repository: repository)).run(const ToolArguments({}));
    expect((listed.output['documents'] as List).single, containsPair('id', 'doc-1'));
    final read = await GetDocumentTool(LoadDocument(repository: repository))
        .run(const ToolArguments({'document_id': 'doc-1'}));
    expect(read.output['content'], _source);
    final missing = await GetDocumentTool(LoadDocument(repository: repository)).run(const ToolArguments({}));
    expect(missing.output['error'], 'invalid_arguments');
  });

  test('create and rename go through the use cases and reject duplicates', () async {
    final create = CreateDocumentTool(CreateDocument(
      repository: repository,
      identifiers: FakeIdentifierGenerator(['new']),
      clock: clock,
    ));
    final created = await create.run(const ToolArguments({'title': 'Nuevo', 'profile': 'english'}));
    expect(created.succeeded, isTrue);
    final duplicate = await create.run(const ToolArguments({'title': 'nuevo', 'profile': 'english'}));
    expect(duplicate.output['error'], 'titleUnavailable');
    final bad = await create.run(const ToolArguments({'title': 'X', 'profile': 'klingon'}));
    expect(bad.output['error'], 'invalid_arguments');
    final rename = RenameDocumentTool(RenameDocument(repository: repository, clock: clock));
    expect((await rename.run(const ToolArguments({'document_id': 'doc-1', 'title': 'Otro'}))).succeeded, isTrue);
    expect(create.needsConfirmation(const ToolArguments({})), isFalse);
  });

  test('edit replaces a unique fragment and reports diagnostics', () async {
    final edit = EditDocumentTool(writer);
    final result = await edit.run(const ToolArguments({
      'document_id': 'doc-1',
      'old_text': 'Escribir 1;',
      'new_text': 'Escribir 2;',
    }));
    expect(result.output['executable'], isTrue);
    expect(repository.documents['doc-1']!.content, contains('Escribir 2;'));
    expect(repository.documents['doc-1']!.revision, 2);
  });

  test('edit refuses missing, ambiguous and out-of-range edits', () async {
    final edit = EditDocumentTool(writer);
    final absent = await edit.run(const ToolArguments({'document_id': 'doc-1', 'old_text': 'nada', 'new_text': 'x'}));
    expect(absent.output['error'], 'edit_not_applicable');
    final ambiguous = await edit.run(const ToolArguments({'document_id': 'doc-1', 'old_text': 'o', 'new_text': 'x'}));
    expect(ambiguous.output['error'], 'edit_not_applicable');
    final far = await edit.run(const ToolArguments({'document_id': 'doc-1', 'offset': 9999, 'new_text': 'x'}));
    expect(far.output['error'], 'edit_not_applicable');
    final unknown = await edit.run(const ToolArguments({'document_id': 'zz', 'new_text': 'x'}));
    expect(unknown.output['error'], 'notFound');
  });

  test('inserting at an offset and replacing everything report errors in the result', () async {
    final inserted = await EditDocumentTool(writer).run(const ToolArguments({'document_id': 'doc-1', 'offset': 0, 'new_text': 'x'}));
    expect(inserted.output['executable'], isFalse);
    final replace = ReplaceDocumentContentTool(writer);
    expect(replace.needsConfirmation(const ToolArguments({})), isTrue);
    final replaced = await replace.run(const ToolArguments({'document_id': 'doc-1', 'content': _source}));
    expect(replaced.output['executable'], isTrue);
    expect(jsonDecode(replaced.encoded())['ok'], isTrue);
  });

  test('delete always confirms and arguments are stored', () async {
    final delete = DeleteDocumentTool(DeleteDocument(repository: repository));
    expect(delete.needsConfirmation(const ToolArguments({})), isTrue);
    final arguments = SetExecutionArgumentsTool(SetExecutionArguments(repository: repository, clock: clock));
    await arguments.run(const ToolArguments({'document_id': 'doc-1', 'arguments': ['a', 'b c']}));
    expect(repository.documents['doc-1']!.executionArguments, ['a', 'b c']);
    final invalid = await arguments.run(const ToolArguments({'document_id': 'doc-1', 'arguments': [1]}));
    expect(invalid.output['error'], 'invalid_arguments');
    expect((await delete.run(const ToolArguments({'document_id': 'doc-1'}))).succeeded, isTrue);
    expect(repository.documents, isEmpty);
  });
}
