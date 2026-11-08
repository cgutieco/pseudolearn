import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/route/session/exercise_session_cubit.dart';
import '../../../application/route/session/exercise_session_state.dart';
import '../../../application/library/library_cubit.dart';
import 'companion_layout.dart';
import 'document_footer.dart';
import 'document_header.dart';
import 'document_workspace.dart';
import 'exercise_strip.dart';
import 'strip_workspace_split.dart';
import 'tab_selector.dart';

final class DocumentColumn extends StatelessWidget {
  final String documentId;
  final DocumentTabKind activeTab;
  final CompanionLayout? companionLayout;
  final bool isAccompanying;
  final bool showsCompanionLabel;
  final Axis companionDirection;
  final bool? exerciseStripExpansion;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final ValueChanged<bool> onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;

  const DocumentColumn({
    super.key,
    required this.documentId,
    required this.activeTab,
    required this.companionLayout,
    required this.isAccompanying,
    required this.showsCompanionLabel,
    required this.companionDirection,
    required this.exerciseStripExpansion,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onToggleExerciseStrip,
    required this.onPace,
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
        exerciseStripExpansion: exerciseStripExpansion,
        onTabSelected: onTabSelected,
        onToggleCompanion: onToggleCompanion,
        onToggleExerciseStrip: onToggleExerciseStrip,
        onPace: onPace,
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
  final bool? exerciseStripExpansion;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final ValueChanged<bool> onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;
  final EditorState editorState;

  const _DocumentColumnContent({
    required this.documentId,
    required this.activeTab,
    required this.companionLayout,
    required this.isAccompanying,
    required this.showsCompanionLabel,
    required this.companionDirection,
    required this.exerciseStripExpansion,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onToggleExerciseStrip,
    required this.onPace,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
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
        Expanded(
          child: StripWorkspaceSplit(
            strip: _ExerciseStripConnector(
              exerciseId: editorState.document?.exerciseId,
              expansion: exerciseStripExpansion,
              onToggleExpand: onToggleExerciseStrip,
            ),
            workspace: ws,
          ),
        ),
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
    return Column(
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
    );
  }
}

final class _ExerciseStripConnector extends StatelessWidget {
  final String? exerciseId;
  final bool? expansion;
  final ValueChanged<bool> onToggleExpand;

  const _ExerciseStripConnector({
    required this.exerciseId,
    required this.expansion,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseId = this.exerciseId;
    if (exerciseId == null) return const SizedBox.shrink();
    return BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
      builder: (context, sessionState) {
        final isExpanded =
            expansion ?? !(sessionState.isCompleted || sessionState.isSolved);
        return ExerciseStrip(
          exerciseId: exerciseId,
          sessionState: sessionState,
          isExpanded: isExpanded,
          onToggleExpand: () => onToggleExpand(!isExpanded),
        );
      },
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
      onToggleOutput: () => context.read<ExecutionCubit>().applyViewAction(
        ExecutionViewAction.toggleOutputPanel,
      ),
    );
  }
}
