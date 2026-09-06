import 'package:bloc/bloc.dart';
import '../../../domain/model/knowledge/content_block.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/document_heading.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/knowledge_repository.dart';
import 'specification_state.dart';

final class SpecificationCubit extends Cubit<SpecificationState> {
  final KnowledgeRepository _repository;

  SpecificationCubit({
    required KnowledgeRepository repository,
  })  : _repository = repository,
        super(const SpecificationState());

  Future<void> loadSpecification({
    required String documentId,
    required UiLanguageId languageId,
    required SyntaxProfileId profileId,
    String? anchor,
  }) async {
    emit(state.copyWith(status: SpecificationStatus.loading));
    try {
      final entry = await _resolveDocumentEntry(languageId, documentId);
      if (entry == null || entry.path == null) {
        emit(state.copyWith(
          status: SpecificationStatus.documentNotFound,
          documentId: () => null,
        ));
        return;
      }

      final blocksResult = await _repository.getDocumentBlocks(
        path: entry.path!,
        profileId: profileId,
        languageId: languageId,
      );
      if (blocksResult is ContentLoadFailed<List<ContentBlock>>) {
        emit(state.copyWith(
          status: SpecificationStatus.error,
          errorMessage: () => blocksResult.detail,
        ));
        return;
      }

      final blocks = (blocksResult as ContentLoaded<List<ContentBlock>>).value;
      _emitLoadedSpecification(documentId, blocks, anchor);
    } catch (e) {
      emit(state.copyWith(
        status: SpecificationStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void selectAnchor(String? anchor) {
    emit(state.copyWith(selectedAnchor: () => anchor));
  }

  void _emitLoadedSpecification(
    String documentId,
    List<ContentBlock> blocks,
    String? anchor,
  ) {
    emit(state.copyWith(
      status: SpecificationStatus.success,
      documentId: () => documentId,
      blocks: blocks,
      headings: _extractHeadings(blocks),
      selectedAnchor: () => anchor,
      errorMessage: () => null,
    ));
  }

  Future<KnowledgeEntry?> _resolveDocumentEntry(
    UiLanguageId languageId,
    String documentId,
  ) async {
    final entriesResult = await _repository.getEntries(languageId);
    if (entriesResult is! ContentLoaded<List<KnowledgeEntry>>) {
      return null;
    }
    return entriesResult.value.cast<KnowledgeEntry?>().firstWhere(
          (e) => e?.id == documentId,
          orElse: () => null,
        );
  }

  List<DocumentHeading> _extractHeadings(List<ContentBlock> blocks) {
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
}
