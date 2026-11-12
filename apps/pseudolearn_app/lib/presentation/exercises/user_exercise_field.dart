import 'package:material_ui/material_ui.dart';
import '../components/field/app_text_field.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/card_metrics.dart';
import '../theme/tokens/field_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_field_spec.dart';

final class UserExerciseField extends StatelessWidget {
  final UserExerciseFieldSpec spec;

  const UserExerciseField({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(child: _FieldLabel(label: spec.label, isRequired: spec.isRequired)),
          const SizedBox(height: FieldMetricsTokens.gapLabelToField),
          AppTextField(
            key: ValueKey('user-exercise-field:${spec.name}'),
            semanticLabel: spec.isRequired
                ? l10n.userExerciseRequiredField(spec.label)
                : l10n.userExerciseOptionalField(spec.label),
            controller: spec.controller,
            placeholder: spec.placeholder,
            helperText: spec.helper,
            minLines: spec.lines,
            textStyle: spec.isCode ? resolveAppTextStyle(context, AppTextVariant.codeEditor) : null,
          ),
        ],
      ),
    );
  }
}

final class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _FieldLabel({required this.label, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Row(
      children: [
        Flexible(child: AppText(label, variant: AppTextVariant.label, color: theme.colors.text.primary)),
        const SizedBox(width: SpacingTokens.space2),
        _RequirementBadge(isRequired: isRequired),
      ],
    );
  }
}

final class _RequirementBadge extends StatelessWidget {
  final bool isRequired;

  const _RequirementBadge({required this.isRequired});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      key: ValueKey(isRequired ? 'user-exercise-required' : 'user-exercise-optional'),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2, vertical: SpacingTokens.spaceHalf),
      decoration: BoxDecoration(
        color: isRequired ? colors.surfaces.brandSubtle : colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radiusInner),
      ),
      child: AppText(
        isRequired ? l10n.userExerciseRequired : l10n.userExerciseOptional,
        variant: AppTextVariant.caption,
        color: isRequired ? colors.text.link : colors.text.secondary,
      ),
    );
  }
}
