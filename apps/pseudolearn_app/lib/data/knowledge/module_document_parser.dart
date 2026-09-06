import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/module_part.dart';
import '../../domain/model/knowledge/module_section.dart';
import 'markdown_block_parser.dart';

final class ModuleDocumentParser {
  static const String partDelimiter = ':::parte ';

  final MarkdownBlockParser _markdown;

  const ModuleDocumentParser({
    MarkdownBlockParser markdown = const MarkdownBlockParser(),
  }) : _markdown = markdown;

  ContentLoadResult<List<ModuleSection>> parse(String source) {
    final sections = <ModuleSection>[];
    ModulePart? currentPart;
    final currentLines = <String>[];

    for (final line in source.split('\n')) {
      if (!line.startsWith(partDelimiter)) {
        currentLines.add(line);
        continue;
      }
      if (currentPart != null) {
        sections.add(_sectionOf(currentPart, currentLines));
      }
      final slug = line.substring(partDelimiter.length).trim();
      final part = ModulePart.fromSlug(slug);
      if (part == null) {
        return ContentLoadFailed(
          failure: ContentLoadFailure.unknownModulePart,
          detail: slug,
        );
      }
      currentPart = part;
      currentLines.clear();
    }

    if (currentPart == null) {
      return const ContentLoadFailed(
        failure: ContentLoadFailure.moduleMalformed,
        detail: partDelimiter,
      );
    }
    sections.add(_sectionOf(currentPart, currentLines));
    return ContentLoaded(sections);
  }

  ModuleSection _sectionOf(ModulePart part, List<String> lines) {
    return ModuleSection(
      part: part,
      blocks: _blocksOf(lines),
    );
  }

  List<ContentBlock> _blocksOf(List<String> lines) {
    return _markdown.parse(lines.join('\n'));
  }
}
