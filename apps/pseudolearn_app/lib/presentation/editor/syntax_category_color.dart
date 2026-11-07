import 'package:flutter/material.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../theme/tokens/syntax_colors.dart';

Color syntaxCategoryColor(HighlightCategory category, AppSyntaxColors colors) {
  return switch (category) {
    HighlightCategory.keywordStructured => colors.keywordStructured,
    HighlightCategory.keywordProcedural => colors.keywordProcedural,
    HighlightCategory.keywordOop => colors.keywordOop,
    HighlightCategory.type => colors.keywordStructured,
    HighlightCategory.literalNumber => colors.literalNumber,
    HighlightCategory.literalString => colors.literalText,
    HighlightCategory.literalBoolean => colors.literalBoolean,
    HighlightCategory.operator => colors.ink,
    HighlightCategory.punctuation => colors.ink,
    HighlightCategory.comment => colors.comment,
    HighlightCategory.identifier => colors.identifier,
  };
}
