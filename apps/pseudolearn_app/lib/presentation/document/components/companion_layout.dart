import 'package:flutter/widgets.dart';
import '../../shell/device_class.dart';
import 'tab_selector.dart';

enum CompanionLayout {
  beside(
    direction: Axis.horizontal,
    editorFlex: 1,
    companionFlex: 1,
    keepsEditorKeys: true,
  ),
  below(
    direction: Axis.vertical,
    editorFlex: 3,
    companionFlex: 2,
    keepsEditorKeys: false,
  );

  final Axis direction;
  final int editorFlex;
  final int companionFlex;
  final bool keepsEditorKeys;

  const CompanionLayout({
    required this.direction,
    required this.editorFlex,
    required this.companionFlex,
    required this.keepsEditorKeys,
  });

  static bool isOfferedFor(DocumentTabKind activeTab) =>
      activeTab != DocumentTabKind.editor;

  static CompanionLayout forDeviceClass(DeviceClass deviceClass) =>
      deviceClass == DeviceClass.expanded ? beside : below;

  static CompanionLayout? resolve({
    required DeviceClass deviceClass,
    required DocumentTabKind activeTab,
    required bool isAccompanying,
    required bool isKeyboardVisible,
  }) {
    if (!isAccompanying || !isOfferedFor(activeTab)) return null;
    final layout = forDeviceClass(deviceClass);
    if (layout == below && isKeyboardVisible) return null;
    return layout;
  }
}
