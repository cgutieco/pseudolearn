import 'package:flutter/widgets.dart';
import '../theme/tokens/motion.dart';

const double _matrixEpsilon = 0.001;

final class DiagramCameraAnimator {
  final TransformationController controller = TransformationController();
  final AnimationController _drive;

  double _originScale = 1.0;
  double _targetScale = 1.0;
  Offset _originTranslation = Offset.zero;
  Offset _targetTranslation = Offset.zero;

  DiagramCameraAnimator({required TickerProvider vsync})
      : _drive = AnimationController(vsync: vsync) {
    _drive.addListener(_writeInterpolatedMatrix);
  }

  void animateTo(Matrix4 target, {required Duration duration}) {
    if (duration == Duration.zero) return jumpTo(target);
    if (_isAlreadyThere(target)) return;
    _originScale = _scaleOf(controller.value);
    _originTranslation = _translationOf(controller.value);
    _targetScale = _scaleOf(target);
    _targetTranslation = _translationOf(target);
    _drive.duration = duration;
    _drive.forward(from: 0.0);
  }

  void jumpTo(Matrix4 target) {
    _drive.stop();
    controller.value = target;
  }

  void stop() => _drive.stop();

  void dispose() {
    _drive.dispose();
    controller.dispose();
  }

  void _writeInterpolatedMatrix() {
    final progress = MotionTokens.easeStandard.transform(_drive.value);
    final scale = _originScale + (_targetScale - _originScale) * progress;
    final translation =
        Offset.lerp(_originTranslation, _targetTranslation, progress)!;
    controller.value = Matrix4.identity()
      ..translateByDouble(translation.dx, translation.dy, 0.0, 1.0)
      ..scaleByDouble(scale, scale, scale, 1.0);
  }

  bool _isAlreadyThere(Matrix4 target) {
    final currentScale = _scaleOf(controller.value);
    final currentTranslation = _translationOf(controller.value);
    return (currentScale - _scaleOf(target)).abs() < _matrixEpsilon &&
        (currentTranslation - _translationOf(target)).distance < _matrixEpsilon;
  }

  double _scaleOf(Matrix4 matrix) => matrix.getMaxScaleOnAxis();

  Offset _translationOf(Matrix4 matrix) {
    final translation = matrix.getTranslation();
    return Offset(translation.x, translation.y);
  }
}
