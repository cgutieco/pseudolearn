import 'package:material_ui/material_ui.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../components/empty/app_empty_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/component_metrics.dart';
import 'diagram_notation_switch.dart';

final class DiagramEmptyState extends StatelessWidget {
  final DiagramNotation notation;
  final bool hasValidAst;
  final List<String> unsupportedKinds;
  final ValueChanged<DiagramNotation>? onNotationSelected;

  const DiagramEmptyState({
    super.key,
    required this.notation,
    required this.hasValidAst,
    this.unsupportedKinds = const [],
    this.onNotationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          AppEmptyState(
            icon: Icons.account_tree_outlined,
            title: l10n.tabDiagrams,
            description: _descriptionOf(l10n),
          ),
          Positioned(
            top: ComponentMetricsTokens.flowCanvasZoomControlsInset,
            right: ComponentMetricsTokens.flowCanvasZoomControlsInset,
            child: DiagramNotationSwitch(
              notation: notation,
              availableWidth: constraints.maxWidth,
              onSelected: onNotationSelected,
            ),
          ),
        ],
      ),
    );
  }

  String _descriptionOf(AppLocalizations l10n) {
    if (unsupportedKinds.isNotEmpty) {
      return l10n.diagramUnsupportedSyntax(unsupportedKinds.join(', '));
    }
    return hasValidAst && notation == DiagramNotation.classDiagram
        ? l10n.classDiagramNoClasses
        : _unavailableDescriptionOf(l10n, notation);
  }
}

String _unavailableDescriptionOf(
  AppLocalizations l10n,
  DiagramNotation notation,
) {
  return switch (notation) {
    DiagramNotation.flowchart => l10n.flowchartEmpty,
    DiagramNotation.structogram => l10n.structogramEmpty,
    DiagramNotation.classDiagram => l10n.classDiagramEmpty,
  };
}
