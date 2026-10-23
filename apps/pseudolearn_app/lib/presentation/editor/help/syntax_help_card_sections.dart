import 'package:flutter/material.dart';
import '../../../domain/model/help/syntax_help.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';

final class SyntaxHelpCardSections extends StatelessWidget {
  final HelpCardSections card;

  const SyntaxHelpCardSections({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.purpose.isNotEmpty)
          _Section(l10n.helpSectionPurpose, [card.purpose]),
        _Section(l10n.helpSectionParts, [
          for (final part in card.parts) part.text,
        ]),
        _Section(l10n.helpSectionConstraints, card.constraints),
        _Section(l10n.helpSectionCommonErrors, card.commonErrors),
        _Section(l10n.helpSectionExamples, [
          for (final example in card.examples)
            '${_kindLabel(l10n, example.kind)}: ${example.label}',
        ]),
      ],
    );
  }
}

String _kindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'executable' => l10n.helpExampleExecutable,
  'accepted' => l10n.helpExampleAccepted,
  _ => l10n.helpExampleDiagnostic,
};

final class _Section extends StatelessWidget {
  final String heading;
  final List<String> lines;

  const _Section(this.heading, this.lines);

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: AppText(heading, variant: AppTextVariant.label),
          ),
          for (final line in lines)
            AppText(line, variant: AppTextVariant.bodySmall),
        ],
      ),
    );
  }
}
