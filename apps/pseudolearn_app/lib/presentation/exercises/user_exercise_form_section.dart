import 'package:material_ui/material_ui.dart';
import '../components/card/app_card.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_field.dart';
import 'user_exercise_field_spec.dart';

final class UserExerciseFormSection extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final List<UserExerciseFieldSpec> fields;

  const UserExerciseFormSection({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeading(step: step, title: title),
            const SizedBox(height: SpacingTokens.space1),
            AppText(description, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
            const SizedBox(height: SpacingTokens.space5),
            for (final field in fields) UserExerciseField(spec: field),
          ],
        ),
      ),
    );
  }
}

final class _SectionHeading extends StatelessWidget {
  final int step;
  final String title;

  const _SectionHeading({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Semantics(
      header: true,
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: SpacingTokens.space6,
              height: SpacingTokens.space6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaces.brandSubtle,
                borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
              ),
              child: AppText('$step', variant: AppTextVariant.label, color: colors.text.link),
            ),
          ),
          const SizedBox(width: SpacingTokens.space3),
          Expanded(child: AppText(title, variant: AppTextVariant.heading4)),
        ],
      ),
    );
  }
}
