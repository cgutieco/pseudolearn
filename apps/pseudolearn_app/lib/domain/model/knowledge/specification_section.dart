import 'content_block.dart';
import 'list_equality.dart';
import 'specification_document.dart';

final class SpecificationSection {
  final String id;
  final SpecificationDocument document;
  final String anchor;
  final int order;
  final String title;
  final List<ContentBlock> blocks;

  const SpecificationSection({
    required this.id,
    required this.document,
    required this.anchor,
    required this.order,
    required this.title,
    required this.blocks,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecificationSection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          document == other.document &&
          anchor == other.anchor &&
          order == other.order &&
          title == other.title &&
          listEquals(blocks, other.blocks);

  @override
  int get hashCode => Object.hash(
        id,
        document,
        anchor,
        order,
        title,
        Object.hashAll(blocks),
      );
}
