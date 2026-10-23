import 'package:bloc/bloc.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/syntax_help_source.dart';
import 'syntax_help_state.dart';

final class SyntaxHelpCubit extends Cubit<SyntaxHelpState> {
  final SyntaxHelpSource _source;

  SyntaxHelpCubit({required SyntaxHelpSource source})
    : _source = source,
      super(const SyntaxHelpState());

  void documentChanged(int revision) {
    if (revision <= state.documentRevision && state.result == null) return;
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
    emit(state.showing(result));
  }

  void dismiss() {
    if (state.result == null) return;
    emit(state.cleared());
  }
}
