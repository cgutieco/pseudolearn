import 'content_block.dart';
import 'list_equality.dart';
import 'module_part.dart';

final class ModuleSection {
  final ModulePart part;
  final List<ContentBlock> blocks;

  const ModuleSection({
    required this.part,
    required this.blocks,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleSection &&
          runtimeType == other.runtimeType &&
          part == other.part &&
          listEquals(blocks, other.blocks);

  @override
  int get hashCode => Object.hash(part, Object.hashAll(blocks));
}
