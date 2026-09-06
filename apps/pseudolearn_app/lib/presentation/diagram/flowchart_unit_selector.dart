import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_unit.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class FlowchartUnitSelector extends StatelessWidget {
  final List<DiagramUnit> units;
  final String? selectedUnitId;
  final ValueChanged<String>? onSelected;

  const FlowchartUnitSelector({
    super.key,
    required this.units,
    required this.selectedUnitId,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final activeUnit = _findActiveUnit(units, selectedUnitId);
    final dec = BoxDecoration(
      color: theme.colors.surfaces.defaultSurface,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
      border: Border.all(color: theme.colors.borders.subtle),
    );
    const pad = EdgeInsets.symmetric(
      horizontal: SpacingTokens.space3,
      vertical: SpacingTokens.space1,
    );

    return Container(
      decoration: dec,
      padding: pad,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activeUnit?.id,
          isDense: true,
          dropdownColor: theme.colors.surfaces.defaultSurface,
          icon: Icon(Icons.arrow_drop_down, color: theme.colors.text.secondary),
          style: _labelStyle(theme.colors.text.primary),
          items: _buildDropdownItems(units),
          onChanged: (id) => id != null ? onSelected?.call(id) : null,
        ),
      ),
    );
  }

  static List<DropdownMenuItem<String>> _buildDropdownItems(
    List<DiagramUnit> units,
  ) {
    return units
        .map((unit) => DropdownMenuItem<String>(
              value: unit.id,
              child: Text(unit.displayName),
            ))
        .toList();
  }

  static DiagramUnit? _findActiveUnit(
    List<DiagramUnit> units,
    String? selectedUnitId,
  ) {
    if (units.isEmpty) return null;
    if (selectedUnitId == null) return units.first;
    for (final unit in units) {
      if (unit.id == selectedUnitId) return unit;
    }
    return units.first;
  }
}

TextStyle _labelStyle(Color color) =>
    TextStyle(color: color, fontSize: 13).inRole(AppFontRole.ui);
