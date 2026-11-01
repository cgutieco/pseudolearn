part of 'editor_cubit.dart';

mixin _EditorSourceReveal on Cubit<EditorState> {
  void revealSource(SourceRange range) {
    final length = state.sourceCode.length;
    final start = range.startOffset.clamp(0, length);
    final end = range.endOffset.clamp(start, length);
    emit(
      state.copyWith(
        pendingEdit: SourceEdit(
          sourceCode: state.sourceCode,
          caret: CaretRange(start: start, end: end),
          revision: (state.pendingEdit?.revision ?? 0) + 1,
          templateActive: state.templateActive,
        ),
      ),
    );
  }
}
