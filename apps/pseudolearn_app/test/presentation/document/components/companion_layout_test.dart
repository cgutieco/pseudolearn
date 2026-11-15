import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/document/components/companion_layout.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/shell/device_class.dart';

CompanionLayout? resolveFor(
  DeviceClass deviceClass, {
  DocumentTabKind activeTab = DocumentTabKind.flowchart,
  bool isAccompanying = true,
  bool isKeyboardVisible = false,
}) {
  return CompanionLayout.resolve(
    deviceClass: deviceClass,
    activeTab: activeTab,
    isAccompanying: isAccompanying,
    isKeyboardVisible: isKeyboardVisible,
  );
}

void main() {
  group('CompanionLayout', () {
    test('the expanded class splits sideways and the narrow ones downwards', () {
      expect(resolveFor(DeviceClass.expanded), CompanionLayout.beside);
      expect(resolveFor(DeviceClass.medium), CompanionLayout.below);
      expect(resolveFor(DeviceClass.compact), CompanionLayout.below);
    });

    test('sideways shares evenly and downwards leaves the editor the larger half', () {
      expect(CompanionLayout.beside.direction, Axis.horizontal);
      expect(CompanionLayout.beside.editorFlex, CompanionLayout.beside.companionFlex);

      expect(CompanionLayout.below.direction, Axis.vertical);
      expect(
        CompanionLayout.below.editorFlex,
        greaterThan(CompanionLayout.below.companionFlex),
      );
    });

    test('only the sideways split has room for the command strip', () {
      expect(CompanionLayout.beside.keepsEditorKeys, isTrue);
      expect(CompanionLayout.below.keepsEditorKeys, isFalse);
    });

    test('nothing accompanies the editor while the toggle is off', () {
      for (final deviceClass in DeviceClass.values) {
        expect(resolveFor(deviceClass, isAccompanying: false), isNull);
      }
    });

    test('the editor tab has nothing to accompany itself with', () {
      expect(CompanionLayout.isOfferedFor(DocumentTabKind.editor), isFalse);
      for (final deviceClass in DeviceClass.values) {
        expect(resolveFor(deviceClass, activeTab: DocumentTabKind.editor), isNull);
      }
    });

    test('every tab other than the editor is offered the companion', () {
      for (final tab in DocumentTabKind.values) {
        final isEditor = tab == DocumentTabKind.editor;
        expect(CompanionLayout.isOfferedFor(tab), isEditor ? isFalse : isTrue);
      }
    });

    test('the on-screen keyboard suspends the vertical split, never the sideways one', () {
      expect(resolveFor(DeviceClass.compact, isKeyboardVisible: true), isNull);
      expect(resolveFor(DeviceClass.medium, isKeyboardVisible: true), isNull);
      expect(
        resolveFor(DeviceClass.expanded, isKeyboardVisible: true),
        CompanionLayout.beside,
      );
    });

    test('the layout a class would use does not depend on the toggle', () {
      expect(CompanionLayout.forDeviceClass(DeviceClass.compact), CompanionLayout.below);
      expect(CompanionLayout.forDeviceClass(DeviceClass.medium), CompanionLayout.below);
      expect(CompanionLayout.forDeviceClass(DeviceClass.expanded), CompanionLayout.beside);
    });
  });
}
