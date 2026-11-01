import 'package:flutter/material.dart';
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
    return Stack(
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

final class _AccessibleTarget extends StatelessWidget {
  final String label;
  final SourceRange? range;
  final ValueChanged<SourceRange>? onSourceSelected;

  const _AccessibleTarget({
    required this.label,
    required this.range,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final target = range;
    final select = onSourceSelected;
    final action = target == null || select == null
        ? null
        : () => select(target);
    return Semantics(
      container: true,
      button: action != null,
      label: label,
      onTap: action,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: action,
        excludeFromSemantics: true,
      ),
    );
  }
}
