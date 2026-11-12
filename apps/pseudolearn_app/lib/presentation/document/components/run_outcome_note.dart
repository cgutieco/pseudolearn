import 'package:material_ui/material_ui.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'run_outcome.dart';

final class RunOutcomeNote extends StatelessWidget {
  final RunOutcome outcome;

  const RunOutcomeNote({super.key, required this.outcome});

  @override
  Widget build(BuildContext context) {
    final colors = outcome.tone(AppThemeExtension.of(context).colors.severities);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space1),
      child: AppText(
        outcome.note ?? '',
        variant: AppTextVariant.caption,
        color: colors.fg,
      ),
    );
  }
}
