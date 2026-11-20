import '../../domain/model/exercises/exercise_reference.dart';
import '../../domain/model/execution/execution_configuration.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/companion/companion_cubit.dart';
import '../../application/companion/companion_source.dart';
import '../../application/companion/companion_view.dart';
import '../../application/diagram/diagram_cubit.dart';
import '../../application/editor/editor_cubit.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_cubit.dart';
import '../../application/execution/execution_state.dart';
import '../../application/execution/step_pace.dart';
import '../../application/route/session/exercise_session_cubit.dart';
import '../../application/route/session/exercise_session_state.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import 'components/document_scaffold_body.dart';
import 'components/tab_selector.dart';

bool _sourceChanged(EditorState previous, EditorState current) =>
    previous.sourceCode != current.sourceCode ||
    previous.document != current.document;

CompanionView _companionOf(DocumentTabKind tab) => switch (tab) {
  DocumentTabKind.flowchart => CompanionView.diagram,
  DocumentTabKind.equivalentCode => CompanionView.equivalentCode,
  _ => CompanionView.none,
};

final class DocumentPage extends StatefulWidget {
  final String documentId;

  const DocumentPage({super.key, required this.documentId});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

final class _DocumentPageState extends State<DocumentPage> {
  DocumentTabKind _activeTab = DocumentTabKind.editor;
  bool _isAccompanying = false;
  bool? _exerciseStripExpansion;

  @override
  void initState() {
    super.initState();
    context.read<EditorCubit>().loadDocument(widget.documentId);
    context.read<ExecutionCubit>().applyViewAction(
      ExecutionViewAction.showOtherTab,
    );
    context.read<CompanionCubit>().show(_companionOf(_activeTab));
  }

  void _onTabSelected(DocumentTabKind tab) {
    setState(() => _activeTab = tab);
    context.read<ExecutionCubit>().applyViewAction(switch (tab) {
      DocumentTabKind.trace => ExecutionViewAction.showTrace,
      DocumentTabKind.tasks => ExecutionViewAction.showTasks,
      _ => ExecutionViewAction.showOtherTab,
    });
    context.read<CompanionCubit>().show(_companionOf(tab));
  }

  void _onPace(BuildContext context, EditorState editorState, StepPace pace) {
    final currentEditor = context.read<EditorCubit>().state;
    if (currentEditor.isDirty) {
      context.read<EditorCubit>().saveDocument();
    }
    final profileId =
        currentEditor.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<ExecutionCubit>().advance(
      pace: pace,
      sourceCode: currentEditor.sourceCode,
      profileId: profileId,
      languageId: languageId,
      configuration: ExecutionConfiguration(
        documentId: widget.documentId,
        arguments: currentEditor.document?.executionArguments ?? const [],
      ),
    );
    if (currentEditor.document?.exerciseId != null && pace == StepPace.toEnd) {
      _onCheckExercise(context, currentEditor);
    }
  }

  void _onEditorStateChanged(BuildContext context, EditorState editorState) {
    final profileId =
        editorState.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<CompanionCubit>().sourceChanged(
      CompanionSource(
        sourceCode: editorState.sourceCode,
        profileId: profileId,
        languageId: languageId,
      ),
    );
    final exerciseId = editorState.document?.exerciseId;
    if (exerciseId != null) {
      context.read<ExerciseSessionCubit>().loadExercise(
        exerciseId: exerciseId,
        edition: ReferenceEdition(language: languageId, profile: profileId),
      );
    }
  }

  void _onCheckExercise(BuildContext context, EditorState editorState) {
    final currentEditor = context.read<EditorCubit>().state;
    if (currentEditor.isDirty) {
      context.read<EditorCubit>().saveDocument();
    }
    final profileId =
        currentEditor.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<ExerciseSessionCubit>().checkSolution(
      sourceCode: currentEditor.sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
  }

  void _onExerciseLoaded(BuildContext context, ExerciseSessionState session) {
    final editorCubit = context.read<EditorCubit>();
    final doc = editorCubit.state.document;
    final starter = session.exercise?.starterCode;
    if (doc != null &&
        _linksTo(doc.exerciseId, session) &&
        editorCubit.state.sourceCode.trim().isEmpty &&
        starter != null &&
        starter.isNotEmpty) {
      final languageId = context.read<SettingsCubit>().state.language;
      editorCubit.updateSourceCode(starter, languageId: languageId);
      editorCubit.saveDocument();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = DocumentScaffoldBody(
      documentId: widget.documentId,
      activeTab: _activeTab,
      isAccompanying: _isAccompanying,
      exerciseStripExpansion: _exerciseStripExpansion,
      onTabSelected: _onTabSelected,
      onToggleCompanion: () =>
          setState(() => _isAccompanying = !_isAccompanying),
      onToggleExerciseStrip: (expanded) =>
          setState(() => _exerciseStripExpansion = expanded),
      onPace: (state, pace) => _onPace(context, state, pace),
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<EditorCubit>().saveDocument();
      },
      child: _EditorListeners(
        onEditorStateChanged: _onEditorStateChanged,
        onExerciseLoaded: _onExerciseLoaded,
        child: body,
      ),
    );
  }
}

final class _EditorListeners extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext, EditorState) onEditorStateChanged;
  final void Function(BuildContext, ExerciseSessionState) onExerciseLoaded;

  const _EditorListeners({
    required this.child,
    required this.onEditorStateChanged,
    required this.onExerciseLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditorCubit, EditorState>(
          listenWhen: _sourceChanged,
          listener: onEditorStateChanged,
        ),
        BlocListener<ExecutionCubit, ExecutionState>(
          listenWhen: (p, c) => p.followedFocus != c.followedFocus,
          listener: (ctx, s) =>
              ctx.read<DiagramCubit>().syncWithFocus(s.followedFocus),
        ),
        BlocListener<ExerciseSessionCubit, ExerciseSessionState>(
          listenWhen: (p, c) => p.exercise != c.exercise && c.exercise != null,
          listener: onExerciseLoaded,
        ),
      ],
      child: child,
    );
  }
}

bool _linksTo(String? exerciseId, ExerciseSessionState session) {
  final exercise = session.exercise;
  return exerciseId != null &&
      exercise != null &&
      ExerciseReference.parse(exerciseId) == exercise.reference;
}
