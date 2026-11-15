import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';

final class ReferenceHeadingView extends StatelessWidget {
  final ReferenceHeading heading;
  final ValueChanged<String> onOpenSection;

  const ReferenceHeadingView({
    super.key,
    required this.heading,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              heading.number,
              variant: AppTextVariant.heading3,
              color: theme.colors.text.tertiary,
            ),
            const SizedBox(width: SpacingTokens.space2),
            Expanded(
              child: ReferenceRunsText(
                runs: heading.runs,
                variant: AppTextVariant.heading3,
                onOpenSection: onOpenSection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
