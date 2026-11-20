import 'package:material_ui/material_ui.dart';

import '../../../domain/model/execution/read_request.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class ReadLineHeader extends StatelessWidget {
  final ReadRequest request;

  const ReadLineHeader({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Row(
        children: [
          _PausedLine(line: request.line),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(
            child: AppText(
              request.statementText,
              variant: AppTextVariant.codeCaption,
              color: theme.colors.text.secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

final class _PausedLine extends StatelessWidget {
  final int line;

  const _PausedLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = AppThemeExtension.of(context).colors.text.tertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.push_pin_outlined,
          size: IconMetricsTokens.iconXs,
          color: color,
        ),
        const SizedBox(width: SpacingTokens.space1),
        AppText(
          l10n.readLineLocation(line),
          variant: AppTextVariant.caption,
          color: color,
        ),
      ],
    );
  }
}
