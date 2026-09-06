import 'package:flutter/animation.dart';

enum MotionSpeed { instant, step, fast, standard, panel, screen }

final class MotionTokens {
  static const Duration motionInstant = Duration.zero;
  static const Duration motionStep = Duration(milliseconds: 90);
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionDefault = Duration(milliseconds: 180);
  static const Duration motionPanel = Duration(milliseconds: 240);
  static const Duration motionScreen = Duration(milliseconds: 300);

  static const Duration tooltipWait = Duration(milliseconds: 500);

  static const Duration motionInstantReduced = Duration.zero;
  static const Duration motionStepReduced = Duration.zero;
  static const Duration motionFastReduced = Duration(milliseconds: 120);
  static const Duration motionDefaultReduced = Duration(milliseconds: 100);
  static const Duration motionPanelReduced = Duration(milliseconds: 100);
  static const Duration motionScreenReduced = Duration(milliseconds: 100);

  static const Curve easeStandard = Cubic(0.20, 0.00, 0.00, 1.00);
  static const Curve easeEnter = Cubic(0.05, 0.70, 0.10, 1.00);
  static const Curve easeExit = Cubic(0.30, 0.00, 0.80, 0.15);
  static const Curve easeLinear = Curves.linear;

  static Duration resolve(MotionSpeed speed, {required bool reduced}) {
    return switch (speed) {
      MotionSpeed.instant => reduced ? motionInstantReduced : motionInstant,
      MotionSpeed.step => reduced ? motionStepReduced : motionStep,
      MotionSpeed.fast => reduced ? motionFastReduced : motionFast,
      MotionSpeed.standard => reduced ? motionDefaultReduced : motionDefault,
      MotionSpeed.panel => reduced ? motionPanelReduced : motionPanel,
      MotionSpeed.screen => reduced ? motionScreenReduced : motionScreen,
    };
  }
}
