import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class DemoOutputView extends StatelessWidget {
  final List<String> lines;

  const DemoOutputView({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    if (lines.isEmpty) {
      return Center(
        child: AppText(
          l10n.outputEmpty,
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space3,
      ),
      itemCount: lines.length,
      itemBuilder: (context, index) => _OutputRow(text: lines[index]),
    );
  }
}

final class _OutputRow extends StatelessWidget {
  final String text;

  const _OutputRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.spaceHalf),
      child: AppText(
        text,
        variant: AppTextVariant.codeEditor,
        color: theme.colors.text.primary,
      ),
    );
  }
}
