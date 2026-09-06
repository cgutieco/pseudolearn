import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

String _labelOf(AppLocalizations l10n, DiagramNotation notation) {
  return switch (notation) {
    DiagramNotation.flowchart => l10n.diagramNotationFlowchart,
    DiagramNotation.structogram => l10n.diagramNotationStructogram,
    DiagramNotation.classDiagram => l10n.diagramNotationClassDiagram,
  };
}

final class DiagramNotationSwitch extends StatelessWidget {
  final DiagramNotation notation;
  final double availableWidth;
  final ValueChanged<DiagramNotation>? onSelected;

  const DiagramNotationSwitch({
    super.key,
    required this.notation,
    required this.availableWidth,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fitsSegmentedBar = availableWidth >=
        ComponentMetricsTokens.diagramNotationSegmentedMinWidth;

    return fitsSegmentedBar
        ? _SegmentedNotationBar(notation: notation, onSelected: onSelected)
        : _CompactNotationDropdown(notation: notation, onSelected: onSelected);
  }
}

const EdgeInsets _compactDropdownPadding = EdgeInsets.symmetric(
  horizontal: SpacingTokens.space3,
  vertical: SpacingTokens.space1,
);

final class _CompactNotationDropdown extends StatelessWidget {
  final DiagramNotation notation;
  final ValueChanged<DiagramNotation>? onSelected;

  const _CompactNotationDropdown({required this.notation, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      padding: _compactDropdownPadding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DiagramNotation>(
          value: notation,
          isDense: true,
          dropdownColor: theme.colors.surfaces.defaultSurface,
          icon: Icon(Icons.arrow_drop_down, color: theme.colors.text.secondary),
          style: TextStyle(color: theme.colors.text.primary, fontSize: 13)
              .inRole(AppFontRole.ui),
          items: _buildItems(l10n),
          onChanged: (selected) =>
              selected != null ? onSelected?.call(selected) : null,
        ),
      ),
    );
  }

  static List<DropdownMenuItem<DiagramNotation>> _buildItems(AppLocalizations l10n) {
    return [
      for (final option in DiagramNotation.values)
        DropdownMenuItem<DiagramNotation>(
          value: option,
          child: Text(_labelOf(l10n, option)),
        ),
    ];
  }
}

final class _SegmentedNotationBar extends StatelessWidget {
  final DiagramNotation notation;
  final ValueChanged<DiagramNotation>? onSelected;

  const _SegmentedNotationBar({required this.notation, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      padding: const EdgeInsets.all(SpacingTokens.space1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in DiagramNotation.values)
            _NotationOption(
              label: _labelOf(l10n, option),
              isSelected: notation == option,
              onTap: () => onSelected?.call(option),
            ),
        ],
      ),
    );
  }
}

const EdgeInsets _optionPadding = EdgeInsets.symmetric(
  horizontal: SpacingTokens.space3,
  vertical: SpacingTokens.space1,
);

final class _NotationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotationOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  BoxDecoration _decorationOf(Color selected, Color plain) => BoxDecoration(
        color: isSelected ? selected : plain,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      );

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final color =
        isSelected ? theme.colors.text.primary : theme.colors.text.secondary;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
          child: Container(
            padding: _optionPadding,
            decoration: _decorationOf(theme.colors.surfaces.raised,
                theme.colors.surfaces.defaultSurface),
            child: AppText(label, variant: AppTextVariant.label, color: color),
          ),
        ),
      ),
    );
  }
}
