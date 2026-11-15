import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/domain/model/documents/document_change.dart';
import '../../fakes/document_fixtures.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_text_entry_modality.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/native_test_engine.dart';

const String _program = 'Algoritmo Test\n  Escribir 1;\nFinAlgoritmo\n';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late InMemoryDocumentRepository repository;
  late EditorCubit cubit;

  setUp(() async {
    repository = InMemoryDocumentRepository(emitsChanges: true);
    cubit = EditorCubit(
      repository: repository,
      analyzer: nativeTestEngine.analyzer,
      completionSource: nativeTestEngine.completionSource,
      keySource: nativeTestEngine.editorKeySource,
      sourceEditor: nativeTestEngine.sourceEditor,
      textEntry: const FakeTextEntryModality(),
      clock: FakeClock(),
    );
    await repository.saveDocument(documentFixture(content: _program));
    await cubit.loadDocument('doc-1');
  });

  tearDown(() => cubit.close());

  test('a newer revision written elsewhere reloads the open document', () async {
    await repository.saveDocument(
      documentFixture(content: 'Algoritmo Test\n  Escribir 2;\nFinAlgoritmo\n', revision: 2),
    );
    await _settle();
    await _settle();
    expect(cubit.state.sourceCode, contains('Escribir 2'));
    expect(cubit.state.document!.revision, 2);
  });

  test('unsaved local edits are never overwritten', () async {
    cubit.updateSourceCode('Algoritmo Test\n  Escribir 9;\nFinAlgoritmo\n');
    await repository.saveDocument(documentFixture(content: 'remote', revision: 7));
    await _settle();
    expect(cubit.state.sourceCode, contains('Escribir 9'));
  });

  test('its own save does not reload', () async {
    cubit.updateSourceCode('Algoritmo Test\n  Escribir 3;\nFinAlgoritmo\n');
    await cubit.saveDocument();
    await _settle();
    expect(cubit.state.isDirty, isFalse);
    expect(cubit.state.document!.revision, 2);
  });

  test('changes to other documents are ignored and deletion is reported', () async {
    repository.announce(const DocumentChange.saved(documentId: 'other', revision: 9));
    await _settle();
    expect(cubit.state.errorMessage, isNull);
    await repository.deleteDocument('doc-1');
    await _settle();
    expect(cubit.state.errorMessage, 'Document not found');
  });
}
