import 'package:bloc/bloc.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../../domain/ports/flowchart_builder.dart';
import '../../domain/ports/structogram_builder.dart';
import 'diagram_projection.dart';
import 'diagram_state.dart';

final class DiagramCubit extends Cubit<DiagramState> {
  final DiagramProjection _projection;

  DiagramCubit({
    required FlowchartBuilder flowchartBuilder,
    required StructogramBuilder structogramBuilder,
    required ClassDiagramBuilder classDiagramBuilder,
  })  : _projection = DiagramProjection(
          flowchartBuilder: flowchartBuilder,
          structogramBuilder: structogramBuilder,
          classDiagramBuilder: classDiagramBuilder,
        ),
        super(const DiagramState.initial());

  void updateDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    emit(_projection.project(
      previous: state,
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    ));
  }

  void selectUnit(String unitId) {
    if (state.selectedUnitId == unitId) return;
    emit(state.copyWith(selectedUnitId: unitId));
  }

  void selectNotation(DiagramNotation notation) {
    if (state.notation == notation) return;
    emit(state.copyWith(notation: notation));
  }

  void syncWithFocus(ExecutionFocus? focus) {
    emit(DiagramProjection.followingFocus(state, focus));
  }

  void clear() {
    emit(const DiagramState.initial());
  }
}
