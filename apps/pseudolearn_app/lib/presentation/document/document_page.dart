import '../../domain/model/exercises/exercise_reference.dart';
import '../../domain/model/execution/execution_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/diagram/diagram_cubit.dart';
import '../../application/editor/editor_cubit.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_cubit.dart';
import '../../application/execution/execution_state.dart';
import '../../application/execution/step_pace.dart';
import '../../application/export/export_cubit.dart';
import '../../application/route/session/exercise_session_cubit.dart';
import '../../application/route/session/exercise_session_state.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import 'components/document_scaffold_body.dart';
import 'components/tab_selector.dart';
import 'dialogs/data_input_dialog.dart';

bool _sourceChanged(EditorState previous, EditorState current) =>
    previous.sourceCode != current.sourceCode ||
    previous.document != current.document;

bool _inputJustRequested(ExecutionState previous, ExecutionState current) =>
    current.status == ExecutionStatus.pausedAwaitingInput &&
    (previous.status != ExecutionStatus.pausedAwaitingInput ||
        current.currentStep.inputWait?.requestId !=
            previous.currentStep.inputWait?.requestId ||
        current.currentStep.inputWait?.taskId !=
            previous.currentStep.inputWait?.taskId);

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
    context.read<ExportCubit>().updateSource(
      sourceCode: editorState.sourceCode,
      profileId: profileId,
    );
    context.read<DiagramCubit>().updateDiagram(
      sourceCode: editorState.sourceCode,
      profileId: profileId,
      languageId: languageId,
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

  void _onInputRequested(BuildContext context, ExecutionState execState) {
    final request = execState.currentStep.inputWait;
    if (request == null) return;
    showDataInputDialog(
      context: context,
      prompt: execState.currentStep.inputPrompt,
      inputWait: request,
      onSubmit: (input) =>
          context.read<ExecutionCubit>().provideInput(request, input),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = DocumentScaffoldBody(
      documentId: widget.documentId,
      activeTab: _activeTab,
      isAccompanying: _isAccompanying,
      exerciseStripExpansion: _exerciseStripExpansion,
      onTabSelected: (tab) => setState(() => _activeTab = tab),
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
        onInputRequested: _onInputRequested,
        onExerciseLoaded: _onExerciseLoaded,
        child: body,
      ),
    );
  }
}

final class _EditorListeners extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext, EditorState) onEditorStateChanged;
  final void Function(BuildContext, ExecutionState) onInputRequested;
  final void Function(BuildContext, ExerciseSessionState) onExerciseLoaded;

  const _EditorListeners({
    required this.child,
    required this.onEditorStateChanged,
    required this.onInputRequested,
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
          listenWhen: _inputJustRequested,
          listener: onInputRequested,
        ),
        BlocListener<ExecutionCubit, ExecutionState>(
          listenWhen: (p, c) => p.currentStep.focus != c.currentStep.focus,
          listener: (ctx, s) =>
              ctx.read<DiagramCubit>().syncWithFocus(s.currentStep.focus),
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
