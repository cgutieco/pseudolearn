import 'package:bloc/bloc.dart';
import '../../../domain/model/analysis/highlight_span.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/syntax_help_source.dart';
import 'help_program_highlighter.dart';
import 'syntax_help_state.dart';

final class SyntaxHelpCubit extends Cubit<SyntaxHelpState> {
  final SyntaxHelpSource _source;
  final HelpProgramHighlighter _highlighter;

  SyntaxHelpCubit({
    required this._source,
    required this._highlighter,
  }) : super(const SyntaxHelpState());

  void documentChanged(int revision) {
    if (revision <= state.documentRevision &&
        state.result == null &&
        state.restingKeyword == null) {
      return;
    }
    if (revision < state.documentRevision) return;
    emit(state.advancedTo(revision));
  }

  void request({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int cursorUtf16,
    required int revision,
  }) {
    if (revision < state.documentRevision) return;
    final result = _source.query(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      cursorUtf16: cursorUtf16,
      revision: revision,
    );
    if (isClosed || result.revision < state.documentRevision) return;
    emit(
      state.showing(
        _highlighter.highlight(
          result,
          profileId: profileId,
          languageId: languageId,
        ),
      ),
    );
  }

  void dismiss() {
    if (state.result == null) return;
    emit(state.cleared());
  }

  void caretMoved({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<HighlightSpan> spans,
    required int cursorUtf16,
    required int revision,
  }) {
    if (revision < state.documentRevision) return;
    final span = _spanAt(spans, cursorUtf16);
    final keyword = _isExplainable(
      span,
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      cursorUtf16: cursorUtf16,
      revision: revision,
    )
        ? span?.range
        : null;
    if (keyword == state.restingKeyword) return;
    emit(state.restingOn(keyword));
  }

  bool _isExplainable(
    HighlightSpan? span, {
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int cursorUtf16,
    required int revision,
  }) {
    if (span == null) return false;
    if (_alwaysExplainableCategories.contains(span.category)) return true;
    if (!_probedCategories.contains(span.category)) return false;
    final result = _source.query(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      cursorUtf16: cursorUtf16,
      revision: revision,
    );
    return result.outcome == HelpOutcome.help;
  }
}

const Set<HighlightCategory> _probedCategories = {
  HighlightCategory.identifier,
  HighlightCategory.literalBoolean,
};

const Set<HighlightCategory> _alwaysExplainableCategories = {
  HighlightCategory.keywordStructured,
  HighlightCategory.keywordProcedural,
  HighlightCategory.keywordOop,
  HighlightCategory.type,
};

HighlightSpan? _spanAt(List<HighlightSpan> spans, int cursorUtf16) {
  for (final span in spans) {
    if (span.range.containsOffset(cursorUtf16) &&
        (_alwaysExplainableCategories.contains(span.category) ||
            _probedCategories.contains(span.category))) {
      return span;
    }
  }
  return null;
}
