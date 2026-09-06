import 'package:flutter/material.dart';
import '../../application/diagram/diagram_state.dart';
import '../../application/diagram/focus_frame_projection.dart';
import '../../domain/model/diagram/diagram_focus_frame.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../shell/design_canvas.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/motion.dart';
import 'diagram_camera_animator.dart';
import 'diagram_controls_overlay.dart';
import 'diagram_empty_state.dart';
import 'flowchart_canvas.dart';
import 'flowchart_viewport.dart';

final class FlowchartTabView extends StatefulWidget {
  final DiagramState state;
  final ExecutionFocus? focus;
  final bool framesSceneOnLayout;
  final bool followsExecutionFocus;
  final ValueChanged<String>? onUnitSelected;
  final ValueChanged<DiagramNotation>? onNotationSelected;

  const FlowchartTabView({
    super.key,
    required this.state,
    this.focus,
    this.framesSceneOnLayout = false,
    this.followsExecutionFocus = false,
    this.onUnitSelected,
    this.onNotationSelected,
  });

  @override
  State<FlowchartTabView> createState() => _FlowchartTabViewState();
}

final class _FlowchartTabViewState extends State<FlowchartTabView>
    with SingleTickerProviderStateMixin {
  late final DiagramCameraAnimator _animator;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _animator = DiagramCameraAnimator(vsync: this);
  }

  @override
  void didUpdateWidget(FlowchartTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_viewport.isEmpty) return;
    if (_movedCameraToFocus(oldWidget)) return;
    _refitOnSceneChange(oldWidget);
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.hasValidAst || widget.state.scene.isEmpty) {
      return DiagramEmptyState(
        notation: widget.state.notation,
        hasValidAst: widget.state.hasValidAst,
        onNotationSelected: widget.onNotationSelected,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _adoptViewport(constraints.biggest);
        return _FlowchartStack(
          controller: _animator.controller,
          state: widget.state,
          focus: widget.focus,
          flowViewport: _flowViewport,
          onUnitSelected: widget.onUnitSelected,
          onNotationSelected: widget.onNotationSelected,
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          onFit: _fitToViewport,
          onInteractionStart: _animator.stop,
        );
      },
    );
  }

  FlowchartViewport get _flowViewport =>
      FlowchartViewport(scene: widget.state.scene, viewport: _viewport);

  DiagramFocusFrame? get _focusFrame => widget.followsExecutionFocus
      ? FocusFrameProjection.frameOf(state: widget.state, focus: widget.focus)
      : null;

  Duration get _cameraDuration =>
      DesignCanvasScope.of(context).motion(MotionSpeed.panel);

  void _adoptViewport(Size viewport) {
    if (viewport == _viewport) return;
    final isFirstMeasure = _viewport.isEmpty;
    _viewport = viewport;
    if (isFirstMeasure && !widget.framesSceneOnLayout && _focusFrame == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _settleViewport();
    });
  }

  void _settleViewport() {
    final frame = _focusFrame;
    if (frame == null) return _fitToViewport();
    _animator.jumpTo(_flowViewport.matrixForFrame(frame));
  }

  bool _movedCameraToFocus(FlowchartTabView oldWidget) {
    if (!widget.followsExecutionFocus) return false;
    final frame = _focusFrame;
    if (frame == null) return _pulledBackAfterFocus(oldWidget);
    final matrix = _flowViewport.matrixForFrame(frame);
    if (_sharesSceneWith(oldWidget)) {
      _animator.animateTo(matrix, duration: _cameraDuration);
    } else {
      _animator.jumpTo(matrix);
    }
    return true;
  }

  bool _pulledBackAfterFocus(FlowchartTabView oldWidget) {
    if (oldWidget.focus == null || widget.focus != null) return false;
    _animator.animateTo(_flowViewport.fitMatrix(), duration: _cameraDuration);
    return true;
  }

  bool _sharesSceneWith(FlowchartTabView oldWidget) =>
      oldWidget.state.notation == widget.state.notation &&
      oldWidget.state.selectedUnitId == widget.state.selectedUnitId &&
      oldWidget.state.scene == widget.state.scene;

  void _refitOnSceneChange(FlowchartTabView oldWidget) {
    final notationChanged = oldWidget.state.notation != widget.state.notation;
    final unitChanged =
        oldWidget.state.selectedUnitId != widget.state.selectedUnitId;
    final sceneChanged = oldWidget.state.scene != widget.state.scene;
    if (notationChanged || !(unitChanged || sceneChanged)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitToViewport();
    });
  }

  void _zoomIn() =>
      _applyScale(_currentScale() + ComponentMetricsTokens.flowCanvasZoomStep);

  void _zoomOut() =>
      _applyScale(_currentScale() - ComponentMetricsTokens.flowCanvasZoomStep);

  double _currentScale() => _animator.controller.value.getMaxScaleOnAxis();

  void _applyScale(double target) =>
      _animator.jumpTo(_flowViewport.matrixForScale(target));

  void _fitToViewport() => _animator.jumpTo(_flowViewport.fitMatrix());
}

final class _FlowchartStack extends StatelessWidget {
  final TransformationController controller;
  final DiagramState state;
  final ExecutionFocus? focus;
  final FlowchartViewport flowViewport;
  final ValueChanged<String>? onUnitSelected;
  final ValueChanged<DiagramNotation>? onNotationSelected;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onInteractionStart;

  const _FlowchartStack({
    required this.controller,
    required this.state,
    required this.focus,
    required this.flowViewport,
    this.onUnitSelected,
    this.onNotationSelected,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onInteractionStart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlowchartCanvas(
          controller: controller,
          state: state,
          focus: focus,
          flowViewport: flowViewport,
          onInteractionStart: onInteractionStart,
        ),
        DiagramControlsOverlay(
          units: state.units,
          selectedUnitId: state.selectedUnitId,
          notation: state.notation,
          onUnitSelected: onUnitSelected,
          onNotationSelected: onNotationSelected,
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
          onFit: onFit,
        ),
      ],
    );
  }
}
