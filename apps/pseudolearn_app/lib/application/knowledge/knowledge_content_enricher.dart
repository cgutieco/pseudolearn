import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/document_heading.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/module_section.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import 'diagram_block_resolver.dart';

final class KnowledgeContentEnricher {
  final DiagramBlockResolver _diagrams;
  final ProgramAnalyzer _analyzer;

  const KnowledgeContentEnricher({
    required DiagramBlockResolver diagrams,
    required ProgramAnalyzer analyzer,
  })  : _diagrams = diagrams,
        _analyzer = analyzer;

  List<ContentBlock> enrichBlocks(
    List<ContentBlock> blocks,
    SyntaxProfileId profile,
    UiLanguageId language,
  ) {
    final diagramResolved = _diagrams.resolve(blocks, profile, language);
    return _highlightCodeBlocks(diagramResolved, profile, language);
  }

  List<DocumentHeading> extractHeadings(List<ContentBlock> blocks) {
    final headings = <DocumentHeading>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block is HeadingBlock) {
        headings.add(DocumentHeading(
          level: block.level,
          text: block.text,
          blockIndex: i,
        ));
      }
    }
    return headings;
  }

  List<DocumentHeading> extractModuleHeadings(List<ModuleSection> sections) {
    final headings = <DocumentHeading>[];
    var globalBlockIndex = 0;
    for (final section in sections) {
      for (final block in section.blocks) {
        if (block is HeadingBlock) {
          headings.add(DocumentHeading(
            level: block.level,
            text: block.text,
            blockIndex: globalBlockIndex,
          ));
        }
        globalBlockIndex++;
      }
    }
    return headings;
  }

  List<KnowledgeEntry> filterEntriesByIds(List<KnowledgeEntry> all, List<String> ids) {
    final result = <KnowledgeEntry>[];
    for (final id in ids) {
      for (final e in all) {
        if (e.id == id || e.anchor == id) {
          result.add(e);
          break;
        }
      }
    }
    return result;
  }

  List<ContentBlock> _highlightCodeBlocks(
    List<ContentBlock> blocks,
    SyntaxProfileId profile,
    UiLanguageId language,
  ) {
    final result = <ContentBlock>[];
    for (final block in blocks) {
      if (block is CodeBlock) {
        final report = _analyzer.analyze(
          sourceCode: block.code,
          profileId: profile,
          languageId: language,
        );
        result.add(CodeBlock(
          code: block.code,
          language: block.language,
          highlightSpans: report.highlightSpans,
          title: block.title,
        ));
      } else {
        result.add(block);
      }
    }
    return result;
  }
}
