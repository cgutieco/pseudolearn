import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/diagram/diagram_accessible_element.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../l10n/generated/app_localizations.dart';

final class ClassDiagramSemanticsLayer extends StatelessWidget {
  final List<DiagramAccessibleElement> elements;
  final ValueChanged<SourceRange>? onSourceSelected;

  const ClassDiagramSemanticsLayer({
    super.key,
    required this.elements,
    this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context)!;
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Stack(
        children: [
          for (final element in elements)
            Positioned(
              left: element.bounds.left,
              top: element.bounds.top,
              width: element.bounds.width,
              height: element.bounds.height,
              child: _AccessibleTarget(
                label: _accessibleLabelOf(element, words),
                range: element.range,
                onSourceSelected: onSourceSelected,
              ),
            ),
        ],
      ),
    );
  }
}

String _accessibleLabelOf(
  DiagramAccessibleElement element,
  AppLocalizations words,
) {
  final kind = element.relationKind;
  if (element.role != DiagramAccessibleRole.relation || kind == null) {
    return element.text;
  }
  final relation = words.diagramRelationAccessible(
    _kindName(kind, words),
    element.fromName,
    element.toName,
  );
  return element.isValid
      ? relation
      : words.diagramRelationInvalidAccessible(
          relation,
          element.diagnostics.join(', '),
        );
}

String _kindName(DiagramEdgeKind kind, AppLocalizations words) =>
    switch (kind) {
      DiagramEdgeKind.generalization => words.diagramRelationGeneralization,
      DiagramEdgeKind.association => words.diagramRelationAssociation,
      DiagramEdgeKind.realization => words.diagramRelationRealization,
      _ => words.diagramRelationUsage,
    };

final class _AccessibleTarget extends StatefulWidget {
  final String label;
  final SourceRange? range;
  final ValueChanged<SourceRange>? onSourceSelected;

  const _AccessibleTarget({
    required this.label,
    required this.range,
    required this.onSourceSelected,
  });

  @override
  State<_AccessibleTarget> createState() => _AccessibleTargetState();
}

final class _AccessibleTargetState extends State<_AccessibleTarget> {
  @override
  Widget build(BuildContext context) {
    final select = widget.onSourceSelected;
    final target = widget.range;
    final action = target == null || select == null
        ? null
        : () => select(target);
    return _FocusableSemanticTarget(label: widget.label, action: action);
  }
}

final class _FocusableSemanticTarget extends StatefulWidget {
  final String label;
  final VoidCallback? action;

  const _FocusableSemanticTarget({required this.label, required this.action});

  @override
  State<_FocusableSemanticTarget> createState() =>
      _FocusableSemanticTargetState();
}

final class _FocusableSemanticTargetState
    extends State<_FocusableSemanticTarget> {
  bool _showFocusHighlight = false;

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    enabled: widget.action != null,
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    },
    actions: {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (intent) {
          widget.action?.call();
          return null;
        },
      ),
    },
    onShowFocusHighlight: (show) {
      if (_showFocusHighlight != show) {
        setState(() => _showFocusHighlight = show);
      }
    },
    child: _AccessibleSurface(
      label: widget.label,
      action: widget.action,
      showFocusHighlight: _showFocusHighlight,
    ),
  );
}

final class _AccessibleSurface extends StatelessWidget {
  final String label;
  final VoidCallback? action;
  final bool showFocusHighlight;

  const _AccessibleSurface({
    required this.label,
    required this.action,
    required this.showFocusHighlight,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: showFocusHighlight
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
          : null,
    ),
    child: Semantics(
      container: true,
      button: action != null,
      label: label,
      onTap: action,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: action,
        excludeFromSemantics: true,
      ),
    ),
  );
}
