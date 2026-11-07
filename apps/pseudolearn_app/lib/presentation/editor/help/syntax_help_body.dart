import 'package:flutter/material.dart';
import '../../../domain/model/help/help_part.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../../domain/model/help/syntax_help.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'syntax_help_card_sections.dart';
import '../../reference/reference_link_button.dart';

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
        if (card != null) ReferenceLinkButton.card(card.id),
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
        if (card != null) _CardHeadline(card: card),
        if (card == null && description != null) ...[
          const SizedBox(height: SpacingTokens.space2),
          AppText(description, variant: AppTextVariant.bodyDefault),
        ],
      ],
    );
  }
}

final class _CardHeadline extends StatelessWidget {
  final HelpCardSections card;

  const _CardHeadline({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final category = card.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.space2),
        if (category != null)
          AppText(
            helpCategoryLabel(l10n, category),
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
        Semantics(
          header: true,
          child: AppText(card.title, variant: AppTextVariant.heading4),
        ),
        AppText(card.summary, variant: AppTextVariant.bodyDefault),
      ],
    );
  }
}

String helpCategoryLabel(AppLocalizations l10n, HelpCategory category) =>
    switch (category) {
      HelpCategory.block => l10n.helpCategoryBlock,
      HelpCategory.instruction => l10n.helpCategoryInstruction,
      HelpCategory.symbol => l10n.helpCategorySymbol,
      HelpCategory.function => l10n.helpCategoryFunction,
      HelpCategory.type => l10n.helpCategoryType,
      HelpCategory.value => l10n.helpCategoryValue,
    };

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
