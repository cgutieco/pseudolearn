import 'package:material_ui/material_ui.dart';
import '../../../domain/model/execution/input_wait.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class DataInputRequestDetails extends StatelessWidget {
  final String? prompt;
  final InputWait inputWait;

  const DataInputRequestDetails({
    super.key,
    required this.prompt,
    required this.inputWait,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.inputDialogTitle,
          variant: AppTextVariant.heading2,
          color: theme.colors.text.primary,
        ),
        const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
        AppText(
          prompt ?? l10n.inputDialogPrompt,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.primary,
        ),
        const SizedBox(height: SpacingTokens.space2),
        AppText(
          l10n.inputRequestIdentity(inputWait.taskId, inputWait.requestId),
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
        ),
      ],
    );
  }
}
