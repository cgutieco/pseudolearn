import '../../domain/model/analysis/source_range.dart';
import 'source_offset_index.dart';

extension SourceOffsetText on SourceOffsetIndex {
  String textBetween(SourceRange range) =>
      sourceCode.substring(range.startOffset, range.endOffset);
}
