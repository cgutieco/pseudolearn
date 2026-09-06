import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/ast_construct.dart';
import '../../../../domain/model/knowledge/exercise_level.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/border_metrics.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class LevelDropdown extends StatelessWidget {
  final ExerciseLevel? selectedLevel;
  final AppLocalizations l10n;
  final ValueChanged<ExerciseLevel?> onChanged;

  const LevelDropdown({
    super.key,
    required this.selectedLevel,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return FilterContainer(
      theme: theme,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExerciseLevel?>(
          value: selectedLevel,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          isDense: true,
          dropdownColor: theme.colors.surfaces.defaultSurface,
          items: _levelItems(l10n),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

List<DropdownMenuItem<ExerciseLevel?>> _levelItems(AppLocalizations l10n) => [
      DropdownMenuItem<ExerciseLevel?>(
        value: null,
        child: AppText(l10n.exerciseFilterAllLevels, variant: AppTextVariant.caption),
      ),
      DropdownMenuItem<ExerciseLevel?>(
        value: ExerciseLevel.reproduce,
        child: AppText(l10n.exerciseLevel1, variant: AppTextVariant.caption),
      ),
      DropdownMenuItem<ExerciseLevel?>(
        value: ExerciseLevel.compose,
        child: AppText(l10n.exerciseLevel2, variant: AppTextVariant.caption),
      ),
      DropdownMenuItem<ExerciseLevel?>(
        value: ExerciseLevel.design,
        child: AppText(l10n.exerciseLevel3, variant: AppTextVariant.caption),
      ),
    ];

final class ConstructDropdown extends StatelessWidget {
  final AstConstruct? selectedConstruct;
  final List<AstConstruct> availableConstructs;
  final AppLocalizations l10n;
  final ValueChanged<AstConstruct?> onChanged;

  const ConstructDropdown({
    super.key,
    required this.selectedConstruct,
    required this.availableConstructs,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return FilterContainer(
      theme: theme,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AstConstruct?>(
          value: selectedConstruct,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          isDense: true,
          dropdownColor: theme.colors.surfaces.defaultSurface,
          items: _constructItems(availableConstructs, l10n),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

List<DropdownMenuItem<AstConstruct?>> _constructItems(
  List<AstConstruct> constructs,
  AppLocalizations l10n,
) =>
    [
      DropdownMenuItem<AstConstruct?>(
        value: null,
        child: AppText(l10n.exerciseFilterAllConstructs, variant: AppTextVariant.caption),
      ),
      for (final construct in constructs)
        DropdownMenuItem<AstConstruct?>(
          value: construct,
          child: AppText(_constructLabel(construct, l10n), variant: AppTextVariant.caption),
        ),
    ];

final class FilterContainer extends StatelessWidget {
  final AppThemeExtension theme;
  final Widget child;

  const FilterContainer({super.key, required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: child,
    );
  }
}

String _constructLabel(AstConstruct construct, AppLocalizations l10n) => switch (construct) {
      AstConstruct.conditional => l10n.exerciseConstructConditional,
      AstConstruct.multipleSelection => l10n.exerciseConstructMultipleSelection,
      AstConstruct.conditionalLoop => l10n.exerciseConstructConditionalLoop,
      AstConstruct.postConditionalLoop => l10n.exerciseConstructPostConditionalLoop,
      AstConstruct.countedLoop => l10n.exerciseConstructCountedLoop,
      AstConstruct.arrayDeclaration => l10n.exerciseConstructArrayDeclaration,
      AstConstruct.subprogram => l10n.exerciseConstructSubprogram,
      AstConstruct.classDeclaration => l10n.exerciseConstructClassDeclaration,
    };
