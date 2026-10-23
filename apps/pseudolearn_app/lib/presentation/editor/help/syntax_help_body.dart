import 'package:flutter/material.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../../domain/model/help/syntax_help.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'syntax_help_card_sections.dart';

final class SyntaxHelpBody extends StatelessWidget {
  final HelpQueryResult result;

  const SyntaxHelpBody({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final help = result.help;
    return switch (result.outcome) {
      HelpOutcome.help || HelpOutcome.symbol when help != null => _HelpContent(
        help: help,
        isSymbol: result.outcome == HelpOutcome.symbol,
      ),
      HelpOutcome.invalidPosition => _HelpMessage(l10n.helpInvalidPosition),
      HelpOutcome.failure => _HelpMessage(l10n.helpFailure),
      _ => _HelpMessage(l10n.helpNoHelp),
    };
  }
}

final class _HelpMessage extends StatelessWidget {
  final String message;

  const _HelpMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return AppText(message, variant: AppTextVariant.bodyDefault);
  }
}

final class _HelpContent extends StatelessWidget {
  final SyntaxHelp help;
  final bool isSymbol;

  const _HelpContent({required this.help, required this.isSymbol});

  @override
  Widget build(BuildContext context) {
    final card = help.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HelpHeadline(help: help),
        _HelpNotes(isSymbol: isSymbol, isPartial: help.isPartial),
        if (card != null) SyntaxHelpCardSections(card: card),
      ],
    );
  }
}

final class _HelpHeadline extends StatelessWidget {
  final SyntaxHelp help;

  const _HelpHeadline({required this.help});

  @override
  Widget build(BuildContext context) {
    final card = help.card;
    final description = help.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(help.headline, variant: AppTextVariant.codeInline),
        if (card != null) ...[
          const SizedBox(height: SpacingTokens.space2),
          Semantics(
            header: true,
            child: AppText(card.title, variant: AppTextVariant.heading4),
          ),
          AppText(card.summary, variant: AppTextVariant.bodyDefault),
        ],
        if (description != null) ...[
          const SizedBox(height: SpacingTokens.space2),
          AppText(description, variant: AppTextVariant.bodyDefault),
        ],
      ],
    );
  }
}

final class _HelpNotes extends StatelessWidget {
  final bool isSymbol;
  final bool isPartial;

  const _HelpNotes({required this.isSymbol, required this.isPartial});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSymbol)
          AppText(
            l10n.helpSymbolNote,
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
        if (isPartial)
          AppText(
            l10n.helpPartialNote,
            variant: AppTextVariant.caption,
            color: theme.colors.severities.warning.fg,
          ),
      ],
    );
  }
}
