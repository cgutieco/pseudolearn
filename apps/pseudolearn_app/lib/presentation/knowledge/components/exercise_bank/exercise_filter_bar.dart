import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/ast_construct.dart';
import '../../../../domain/model/knowledge/exercise_level.dart';
import '../../../components/button/app_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens/spacing.dart';
import 'exercise_filter_dropdowns.dart';

final class ExerciseFilterBar extends StatelessWidget {
  final ExerciseLevel? selectedLevel;
  final AstConstruct? selectedConstruct;
  final List<AstConstruct> availableConstructs;
  final bool isAnyFilterActive;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;

  const ExerciseFilterBar({
    super.key,
    required this.selectedLevel,
    required this.selectedConstruct,
    required this.availableConstructs,
    required this.isAnyFilterActive,
    required this.onLevelSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _FilterBarRow(
        selectedLevel: selectedLevel,
        selectedConstruct: selectedConstruct,
        availableConstructs: availableConstructs,
        isAnyFilterActive: isAnyFilterActive,
        l10n: l10n,
        onLevelSelected: onLevelSelected,
        onConstructSelected: onConstructSelected,
        onClearFilters: onClearFilters,
      ),
    );
  }
}

final class _FilterBarRow extends StatelessWidget {
  final ExerciseLevel? selectedLevel;
  final AstConstruct? selectedConstruct;
  final List<AstConstruct> availableConstructs;
  final bool isAnyFilterActive;
  final AppLocalizations l10n;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;

  const _FilterBarRow({
    required this.selectedLevel,
    required this.selectedConstruct,
    required this.availableConstructs,
    required this.isAnyFilterActive,
    required this.l10n,
    required this.onLevelSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LevelDropdown(selectedLevel: selectedLevel, l10n: l10n, onChanged: onLevelSelected),
        const SizedBox(width: SpacingTokens.space2),
        ConstructDropdown(
          selectedConstruct: selectedConstruct,
          availableConstructs: availableConstructs,
          l10n: l10n,
          onChanged: onConstructSelected,
        ),
        if (isAnyFilterActive) ...[
          const SizedBox(width: SpacingTokens.space2),
          _ClearFilterButton(label: l10n.exerciseClearFilters, onPressed: onClearFilters),
        ],
      ],
    );
  }
}

final class _ClearFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ClearFilterButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      icon: Icons.clear_rounded,
      variant: AppButtonVariant.tertiary,
      onPressed: onPressed,
    );
  }
}
