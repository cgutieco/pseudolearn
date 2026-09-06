import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/spec/specification_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/spec/specification_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_knowledge_repository.dart';

void main() {
  group('SpecificationCubit (CON-F9)', () {
    late FakeKnowledgeRepository repository;
    late SpecificationCubit cubit;

    const entryEspI = KnowledgeEntry(
      id: 'pseudocode-imperative-spec',
      title: 'Especificación Imperativa',
      summary: 'ESP-I',
      path: 'spec/spec-imperative.md',
      type: KnowledgeEntryType.specificationSection,
    );

    const blocksEspI = <ContentBlock>[
      HeadingBlock(level: 1, text: 'ESP-I: Pseudocódigo Imperativo'),
      ParagraphBlock(text: 'Introducción a la especificación.'),
      HeadingBlock(level: 2, text: '§4 Tipos de datos'),
      ParagraphBlock(text: 'Detalle de tipos.'),
    ];

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: [entryEspI],
        blocksByPath: {'spec/spec-imperative.md': blocksEspI},
      );
      cubit = SpecificationCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and empty blocks', () {
      expect(cubit.state.status, SpecificationStatus.initial);
      expect(cubit.state.blocks, isEmpty);
      expect(cubit.state.headings, isEmpty);
      expect(cubit.state.selectedAnchor, isNull);
    });

    test('loadSpecification extracts headings and sets anchor', () async {
      await cubit.loadSpecification(
        documentId: 'pseudocode-imperative-spec',
        languageId: UiLanguageId.spanish,
        profileId: SyntaxProfileId.classicSpanish,
        anchor: 'tipos-de-datos',
      );

      expect(cubit.state.status, SpecificationStatus.success);
      expect(cubit.state.documentId, 'pseudocode-imperative-spec');
      expect(cubit.state.blocks.length, 4);
      expect(cubit.state.headings, [
        const DocumentHeading(level: 1, text: 'ESP-I: Pseudocódigo Imperativo', blockIndex: 0),
        const DocumentHeading(level: 2, text: '§4 Tipos de datos', blockIndex: 2),
      ]);
      expect(cubit.state.selectedAnchor, 'tipos-de-datos');
    });

    test('loadSpecification with non-existent documentId emits documentNotFound', () async {
      await cubit.loadSpecification(
        documentId: 'unknown-spec',
        languageId: UiLanguageId.spanish,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, SpecificationStatus.documentNotFound);
      expect(cubit.state.documentId, isNull);
      expect(cubit.state.blocks, isEmpty);
    });

    test('selectAnchor updates selectedAnchor in state', () {
      cubit.selectAnchor('seccion-1');
      expect(cubit.state.selectedAnchor, 'seccion-1');

      cubit.selectAnchor(null);
      expect(cubit.state.selectedAnchor, isNull);
    });
  });
}
