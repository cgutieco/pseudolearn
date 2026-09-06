import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/diagram/diagram_cubit.dart';
import '../../application/editor/editor_cubit.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_cubit.dart';
import '../../application/execution/execution_state.dart';
import '../../application/execution/step_pace.dart';
import '../../application/export/export_cubit.dart';
import '../../application/knowledge/session/exercise_session_cubit.dart';
import '../../application/knowledge/session/exercise_session_state.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import '../theme/app_theme.dart';
import 'components/companion_layout.dart';
import 'components/document_column.dart';
import 'components/tab_selector.dart';
import 'dialogs/data_input_dialog.dart';

bool _sourceChanged(EditorState previous, EditorState current) =>
    previous.sourceCode != current.sourceCode || previous.document != current.document;

bool _inputJustRequested(ExecutionState previous, ExecutionState current) =>
    current.status == ExecutionStatus.pausedAwaitingInput &&
    previous.status != ExecutionStatus.pausedAwaitingInput;

final class DocumentPage extends StatefulWidget {
  final String documentId;

  const DocumentPage({super.key, required this.documentId});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

final class _DocumentPageState extends State<DocumentPage> {
  DocumentTabKind _activeTab = DocumentTabKind.editor;
  bool _isAccompanying = false;
  bool _isExerciseStripExpanded = true;

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
    final profileId = currentEditor.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<ExecutionCubit>().advance(
          pace: pace,
          sourceCode: currentEditor.sourceCode,
          profileId: profileId,
          languageId: languageId,
        );
    if (currentEditor.document?.exerciseId != null && pace == StepPace.toEnd) {
      _onCheckExercise(context, currentEditor);
    }
  }

  void _onEditorStateChanged(BuildContext context, EditorState editorState) {
    final profileId = editorState.document?.profileId ?? SyntaxProfileId.classicSpanish;
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
            exerciseIdOrPath: exerciseId,
            languageId: languageId,
          );
    }
  }

  void _onCheckExercise(BuildContext context, EditorState editorState) {
    final currentEditor = context.read<EditorCubit>().state;
    if (currentEditor.isDirty) {
      context.read<EditorCubit>().saveDocument();
    }
    final profileId = currentEditor.document?.profileId ?? SyntaxProfileId.classicSpanish;
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
        doc.exerciseId == session.exercise?.id &&
        editorCubit.state.sourceCode.trim().isEmpty &&
        starter != null &&
        starter.isNotEmpty) {
      final languageId = context.read<SettingsCubit>().state.language;
      editorCubit.updateSourceCode(starter, languageId: languageId);
      editorCubit.saveDocument();
    }
  }

  void _onInputRequested(BuildContext context, ExecutionState execState) {
    showDataInputDialog(
      context: context,
      prompt: execState.currentStep.inputPrompt,
      onSubmit: (input) => context.read<ExecutionCubit>().provideInput(input),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _DocumentScaffoldBody(
      documentId: widget.documentId,
      activeTab: _activeTab,
      isAccompanying: _isAccompanying,
      isExerciseStripExpanded: _isExerciseStripExpanded,
      onTabSelected: (tab) => setState(() => _activeTab = tab),
      onToggleCompanion: () => setState(() => _isAccompanying = !_isAccompanying),
      onToggleExerciseStrip: () =>
          setState(() => _isExerciseStripExpanded = !_isExerciseStripExpanded),
      onPace: (state, pace) => _onPace(context, state, pace),
      onCheckExercise: (state) => _onCheckExercise(context, state),
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
          listener: (ctx, s) => ctx.read<DiagramCubit>().syncWithFocus(s.currentStep.focus),
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

final class _DocumentScaffoldBody extends StatelessWidget {
  final String documentId;
  final DocumentTabKind activeTab;
  final bool isAccompanying;
  final bool isExerciseStripExpanded;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final VoidCallback onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;
  final ValueChanged<EditorState> onCheckExercise;

  const _DocumentScaffoldBody({
    required this.documentId,
    required this.activeTab,
    required this.isAccompanying,
    required this.isExerciseStripExpanded,
    required this.onTabSelected,
    required this.onToggleCompanion,
    required this.onToggleExerciseStrip,
    required this.onPace,
    required this.onCheckExercise,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final deviceClass = canvas.deviceClass;

    return Scaffold(
      backgroundColor: AppThemeExtension.of(context).colors.surfaces.canvas,
      body: SafeArea(
        child: DocumentColumn(
          documentId: documentId,
          activeTab: activeTab,
          companionLayout: CompanionLayout.resolve(
            deviceClass: deviceClass,
            activeTab: activeTab,
            isAccompanying: isAccompanying,
            isKeyboardVisible: canvas.isKeyboardVisible,
          ),
          isAccompanying: isAccompanying,
          showsCompanionLabel: deviceClass != DeviceClass.compact,
          companionDirection: CompanionLayout.forDeviceClass(deviceClass).direction,
          isExerciseStripExpanded: isExerciseStripExpanded,
          onTabSelected: onTabSelected,
          onToggleCompanion: onToggleCompanion,
          onToggleExerciseStrip: onToggleExerciseStrip,
          onPace: onPace,
          onCheckExercise: onCheckExercise,
        ),
      ),
    );
  }
}
