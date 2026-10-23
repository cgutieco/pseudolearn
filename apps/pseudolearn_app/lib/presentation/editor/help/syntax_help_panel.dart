import 'package:flutter/material.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'syntax_help_body.dart';

final class SyntaxHelpPanel extends StatelessWidget {
  final HelpQueryResult result;
  final VoidCallback onClose;

  const SyntaxHelpPanel({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.helpPanelLabel,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.surfaces.defaultSurface,
          border: Border(top: BorderSide(color: theme.colors.borders.subtle)),
        ),
        constraints: const BoxConstraints(maxHeight: _maxPanelHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HelpPanelHeader(onClose: onClose),
            _HelpPanelScroll(result: result),
          ],
        ),
      ),
    );
  }
}

final class _HelpPanelScroll extends StatelessWidget {
  final HelpQueryResult result;

  const _HelpPanelScroll({required this.result});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.space4),
        child: SyntaxHelpBody(result: result),
      ),
    );
  }
}

final class _HelpPanelTitle extends StatelessWidget {
  const _HelpPanelTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Semantics(
      header: true,
      child: AppText(
        l10n.helpPanelLabel,
        variant: AppTextVariant.label,
        color: theme.colors.text.secondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

const double _maxPanelHeight = SpacingTokens.space20 * 3;

final class _HelpPanelHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _HelpPanelHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Container(
      color: theme.colors.surfaces.subtle,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Row(
        children: [
          const Expanded(child: _HelpPanelTitle()),
          AppIconButton(
            icon: Icons.close,
            semanticLabel: l10n.helpClose,
            variant: AppButtonVariant.tertiary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
