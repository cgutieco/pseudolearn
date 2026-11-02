import 'package:flutter/material.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/app_theme.dart';
import 'companion_layout.dart';
import 'document_column.dart';
import 'tab_selector.dart';

final class DocumentScaffoldBody extends StatelessWidget {
  final String documentId;
  final DocumentTabKind activeTab;
  final bool isAccompanying;
  final bool isExerciseStripExpanded;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final VoidCallback onToggleCompanion;
  final VoidCallback onToggleExerciseStrip;
  final void Function(EditorState, StepPace) onPace;
  final ValueChanged<EditorState> onCheckExercise;

  const DocumentScaffoldBody({
    super.key,
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
    return Scaffold(
      backgroundColor: AppThemeExtension.of(context).colors.surfaces.canvas,
      body: SafeArea(
        child: DocumentColumn(
          documentId: documentId,
          activeTab: activeTab,
          companionLayout: CompanionLayout.resolve(
            deviceClass: canvas.deviceClass,
            activeTab: activeTab,
            isAccompanying: isAccompanying,
            isKeyboardVisible: canvas.isKeyboardVisible,
          ),
          isAccompanying: isAccompanying,
          showsCompanionLabel: canvas.deviceClass != DeviceClass.compact,
          companionDirection: CompanionLayout.forDeviceClass(
            canvas.deviceClass,
          ).direction,
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
