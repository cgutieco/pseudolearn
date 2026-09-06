import '../../../domain/model/knowledge/content_block.dart';
import '../../../domain/model/knowledge/document_heading.dart';

enum SpecificationStatus {
  initial,
  loading,
  success,
  error,
  documentNotFound,
}

final class SpecificationState {
  final SpecificationStatus status;
  final String? documentId;
  final List<ContentBlock> blocks;
  final List<DocumentHeading> headings;
  final String? selectedAnchor;
  final String? errorMessage;

  const SpecificationState({
    this.status = SpecificationStatus.initial,
    this.documentId,
    this.blocks = const [],
    this.headings = const [],
    this.selectedAnchor,
    this.errorMessage,
  });

  SpecificationState copyWith({
    SpecificationStatus? status,
    String? Function()? documentId,
    List<ContentBlock>? blocks,
    List<DocumentHeading>? headings,
    String? Function()? selectedAnchor,
    String? Function()? errorMessage,
  }) {
    return SpecificationState(
      status: status ?? this.status,
      documentId: documentId != null ? documentId() : this.documentId,
      blocks: blocks ?? this.blocks,
      headings: headings ?? this.headings,
      selectedAnchor: selectedAnchor != null ? selectedAnchor() : this.selectedAnchor,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
