import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/knowledge/session/exercise_session_cubit.dart';
import '../../../application/knowledge/session/exercise_session_state.dart';
import '../../../application/library/library_cubit.dart';
import 'companion_layout.dart';
import 'document_footer.dart';
import 'document_header.dart';
import 'document_workspace.dart';
import 'exercise_strip.dart';
import 'tab_selector.dart';

final class DocumentColumn extends StatelessWidget {
  final String documentId;
  final DocumentTabKind activeTab;
  final CompanionLayout? companionLayout;
  final bool isAccompanying;
  final bool showsCompanionLabel;
  final Axis companionDirection;
  final bool isExerciseStripExpanded;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final VoidCallback onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;
  final ValueChanged<EditorState> onCheckExercise;

  const DocumentColumn({
    super.key,
    required this.documentId,
    required this.activeTab,
    required this.companionLayout,
    required this.isAccompanying,
    required this.showsCompanionLabel,
    required this.companionDirection,
    required this.isExerciseStripExpanded,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onToggleExerciseStrip,
    required this.onPace,
    required this.onCheckExercise,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editorState) => _DocumentColumnContent(
        documentId: documentId,
        activeTab: activeTab,
        companionLayout: companionLayout,
        isAccompanying: isAccompanying,
        showsCompanionLabel: showsCompanionLabel,
        companionDirection: companionDirection,
        isExerciseStripExpanded: isExerciseStripExpanded,
        onTabSelected: onTabSelected,
        onToggleCompanion: onToggleCompanion,
        onToggleExerciseStrip: onToggleExerciseStrip,
        onPace: onPace,
        onCheckExercise: onCheckExercise,
        editorState: editorState,
      ),
    );
  }
}

final class _DocumentColumnContent extends StatelessWidget {
  final String documentId;
  final DocumentTabKind activeTab;
  final CompanionLayout? companionLayout;
  final bool isAccompanying;
  final bool showsCompanionLabel;
  final Axis companionDirection;
  final bool isExerciseStripExpanded;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final VoidCallback onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;
  final ValueChanged<EditorState> onCheckExercise;
  final EditorState editorState;

  const _DocumentColumnContent({
    required this.documentId,
    required this.activeTab,
    required this.companionLayout,
    required this.isAccompanying,
    required this.showsCompanionLabel,
    required this.companionDirection,
    required this.isExerciseStripExpanded,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onToggleExerciseStrip,
    required this.onPace,
    required this.onCheckExercise,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseId = editorState.document?.exerciseId;
    final ws = _WorkspaceSection(
      activeTab: activeTab,
      companionLayout: companionLayout,
      isAccompanying: isAccompanying,
      showsCompanionLabel: showsCompanionLabel,
      companionDirection: companionDirection,
      onTabSelected: onTabSelected,
      onToggleCompanion: onToggleCompanion,
      onRun: () => onPace(editorState, StepPace.toEnd),
    );

    return Column(
      children: [
        _Header(documentId: documentId),
        if (exerciseId != null)
          _ExerciseStripConnector(
            exerciseId: exerciseId,
            isExpanded: isExerciseStripExpanded,
            onToggleExpand: onToggleExerciseStrip,
            onCheck: () => onCheckExercise(editorState),
          ),
        ws,
        _Footer(onPace: onPace),
      ],
    );
  }
}

final class _Header extends StatelessWidget {
  final String documentId;

  const _Header({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return DocumentHeader(
      onBack: () {
        context.read<EditorCubit>().saveDocument();
        context.pop();
      },
      onTitleChanged: (title) =>
          context.read<LibraryCubit>().renameDocument(documentId, title),
    );
  }
}

final class _WorkspaceSection extends StatelessWidget {
  final DocumentTabKind activeTab;
  final CompanionLayout? companionLayout;
  final bool isAccompanying;
  final bool showsCompanionLabel;
  final Axis companionDirection;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final VoidCallback onRun;

  const _WorkspaceSection({
    required this.activeTab,
    required this.companionLayout,
    required this.isAccompanying,
    required this.showsCompanionLabel,
    required this.companionDirection,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabSelector(
            activeTab: activeTab,
            onTabSelected: onTabSelected,
            canAccompany: CompanionLayout.isOfferedFor(activeTab),
            isAccompanying: isAccompanying,
            showsCompanionLabel: showsCompanionLabel,
            companionDirection: companionDirection,
            onToggleCompanion: onToggleCompanion,
          ),
          Expanded(
            child: DocumentWorkspace(
              activeTab: activeTab,
              companionLayout: companionLayout,
              onRun: onRun,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ExerciseStripConnector extends StatelessWidget {
  final String exerciseId;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onCheck;

  const _ExerciseStripConnector({
    required this.exerciseId,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
      builder: (context, sessionState) => ExerciseStrip(
        exerciseId: exerciseId,
        sessionState: sessionState,
        isExpanded: isExpanded,
        onToggleExpand: onToggleExpand,
        onCheck: onCheck,
      ),
    );
  }
}

final class _Footer extends StatelessWidget {
  final void Function(EditorState, StepPace) onPace;

  const _Footer({required this.onPace});

  @override
  Widget build(BuildContext context) {
    return DocumentFooter(
      onPace: onPace,
      onStop: () => context.read<ExecutionCubit>().stop(),
      onToggleOutput: () => context.read<ExecutionCubit>().toggleOutputPanel(),
    );
  }
}
