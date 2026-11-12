import 'package:material_ui/material_ui.dart';
import '../../domain/model/reference/reference_section.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'reference_runs_text.dart';

final class ReferenceSectionHeader extends StatelessWidget {
  final ReferenceSection section;
  final ValueChanged<String> onOpenSection;

  const ReferenceSectionHeader({
    super.key,
    required this.section,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: Semantics(
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              section.number,
              variant: AppTextVariant.overline,
              color: theme.colors.text.tertiary,
            ),
            ReferenceRunsText(
              runs: section.title,
              variant: AppTextVariant.heading2,
              onOpenSection: onOpenSection,
            ),
          ],
        ),
      ),
    );
  }
}
