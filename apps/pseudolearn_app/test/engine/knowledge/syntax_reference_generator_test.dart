import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/knowledge/syntax_reference_generator.dart';

void main() {
  group('SyntaxReferenceGenerator (PANT-03-F2)', () {
    const generator = SyntaxReferenceGenerator();

    test('generates reference entries for both profiles with type reference', () {
      final entries = generator.getReferenceEntries();

      expect(entries.length, 2);
      expect(entries.every((e) => e.type == KnowledgeEntryType.reference), isTrue);

      final spanishEntry = entries.firstWhere((e) => e.profileId == SyntaxProfileId.classicSpanish);
      final englishEntry = entries.firstWhere((e) => e.profileId == SyntaxProfileId.english);

      expect(spanishEntry.id, 'reference-classic-spanish');
      expect(englishEntry.id, 'reference-english');
    });

    test('generates structured content blocks for classic spanish profile', () {
      final blocks = generator.getBlocksForProfile(SyntaxProfileId.classicSpanish);

      expect(blocks, isNotEmpty);
      expect(blocks.whereType<HeadingBlock>().length, greaterThanOrEqualTo(3));
      expect(blocks.whereType<ListBlock>().length, greaterThanOrEqualTo(3));

      final allListItems = blocks.whereType<ListBlock>().expand((l) => l.items).toList();
      expect(allListItems, contains('Proceso'));
      expect(allListItems, contains('Definir'));
      expect(allListItems, contains('Entero'));
    });

    test('generates structured content blocks for english profile', () {
      final blocks = generator.getBlocksForProfile(SyntaxProfileId.english);

      expect(blocks, isNotEmpty);
      final allListItems = blocks.whereType<ListBlock>().expand((l) => l.items).toList();
      expect(allListItems, contains('algorithm'));
      expect(allListItems, contains('define'));
      expect(allListItems, contains('integer'));
    });
  });
}
