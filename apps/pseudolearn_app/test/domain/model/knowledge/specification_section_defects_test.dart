import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_defect.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_section.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_section_defects.dart';

SpecificationSection _section({
  String id = 'esp-i-datos',
  String anchor = 'datos',
  String title = 'Datos',
  List<ContentBlock> blocks = const [ParagraphBlock(text: 'Cinco tipos.')],
}) {
  return SpecificationSection(
    id: id,
    document: SpecificationDocument.imperative,
    anchor: anchor,
    order: 1,
    title: title,
    blocks: blocks,
  );
}

void main() {
  group('findSpecificationSectionDefects', () {
    test('a complete section has no defects', () {
      expect(findSpecificationSectionDefects(_section()), isEmpty);
    });

    test('an empty anchor is reported', () {
      expect(
        findSpecificationSectionDefects(_section(anchor: '  ')),
        contains(ContentDefect.emptyAnchor),
      );
    });

    test('a section without blocks is reported', () {
      expect(
        findSpecificationSectionDefects(_section(blocks: const [])),
        contains(ContentDefect.sectionWithoutBlocks),
      );
    });

    test('an empty identifier and an empty title are reported', () {
      final defects = findSpecificationSectionDefects(
        _section(id: '', title: '   '),
      );

      expect(defects, containsAll([
        ContentDefect.emptyIdentifier,
        ContentDefect.emptyTitle,
      ]));
    });

    test('a one character anchor is valid', () {
      expect(findSpecificationSectionDefects(_section(anchor: 'd')), isEmpty);
    });
  });
}
