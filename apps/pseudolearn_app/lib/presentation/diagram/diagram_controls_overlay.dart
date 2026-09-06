import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/diagram/diagram_unit.dart';
import '../theme/tokens/component_metrics.dart';
import 'diagram_notation_switch.dart';
import 'flowchart_unit_selector.dart';
import 'flowchart_zoom_controls.dart';

const double _inset = ComponentMetricsTokens.flowCanvasZoomControlsInset;

final class DiagramControlsOverlay extends StatelessWidget {
  final List<DiagramUnit> units;
  final String? selectedUnitId;
  final DiagramNotation notation;
  final ValueChanged<String>? onUnitSelected;
  final ValueChanged<DiagramNotation>? onNotationSelected;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;

  const DiagramControlsOverlay({
    super.key,
    required this.units,
    required this.selectedUnitId,
    required this.notation,
    this.onUnitSelected,
    this.onNotationSelected,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          if (units.length > 1)
            _UnitSlot(
              units: units,
              selectedUnitId: selectedUnitId,
              onSelected: onUnitSelected,
            ),
          _NotationSlot(
            notation: notation,
            availableWidth: constraints.maxWidth,
            onSelected: onNotationSelected,
          ),
          _ZoomSlot(onZoomIn: onZoomIn, onZoomOut: onZoomOut, onFit: onFit),
        ],
      ),
    );
  }
}

final class _UnitSlot extends StatelessWidget {
  final List<DiagramUnit> units;
  final String? selectedUnitId;
  final ValueChanged<String>? onSelected;

  const _UnitSlot({
    required this.units,
    required this.selectedUnitId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _inset,
      left: _inset,
      child: FlowchartUnitSelector(
        units: units,
        selectedUnitId: selectedUnitId,
        onSelected: onSelected,
      ),
    );
  }
}

final class _NotationSlot extends StatelessWidget {
  final DiagramNotation notation;
  final double availableWidth;
  final ValueChanged<DiagramNotation>? onSelected;

  const _NotationSlot({
    required this.notation,
    required this.availableWidth,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _inset,
      right: _inset,
      child: DiagramNotationSwitch(
        notation: notation,
        availableWidth: availableWidth,
        onSelected: onSelected,
      ),
    );
  }
}

final class _ZoomSlot extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;

  const _ZoomSlot({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: _inset,
      bottom: _inset,
      child: FlowchartZoomControls(
        onZoomIn: onZoomIn,
        onZoomOut: onZoomOut,
        onResetZoom: onFit,
      ),
    );
  }
}
