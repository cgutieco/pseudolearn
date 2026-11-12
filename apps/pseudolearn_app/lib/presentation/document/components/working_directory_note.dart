import 'package:material_ui/material_ui.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class WorkingDirectoryNote extends StatelessWidget {
  final String? directory;

  const WorkingDirectoryNote({super.key, required this.directory});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final path = directory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.executionWorkingDirectoryHelp,
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
        if (path != null) ...[
          const SizedBox(height: SpacingTokens.space1),
          SelectableText(
            path,
            style: resolveAppTextStyle(
              context,
              AppTextVariant.codeCaption,
              color: theme.colors.text.tertiary,
            ),
          ),
        ],
      ],
    );
  }
}
