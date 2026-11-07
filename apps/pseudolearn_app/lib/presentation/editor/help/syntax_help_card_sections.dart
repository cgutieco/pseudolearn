import 'package:flutter/material.dart';
import '../../../domain/model/help/help_part.dart';
import '../../../domain/model/help/help_program.dart';
import '../../../domain/model/help/syntax_help.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'help_code_views.dart';

final class SyntaxHelpCardSections extends StatelessWidget {
  final HelpCardSections card;

  const SyntaxHelpCardSections({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = card.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.form.isNotEmpty)
          _Section(l10n.helpSectionHowToWrite, [HelpFormView(lines: card.form)]),
        if (card.parts.isNotEmpty)
          _Section(l10n.helpSectionEachPart, [
            for (final part in card.parts) _PartRow(part: part),
          ]),
        if (result != null)
          _Section(l10n.helpSectionResult, [_Prose(result)]),
        if (card.rules.isNotEmpty)
          _Section(l10n.helpSectionRules, [
            for (final rule in card.rules) _Prose('• $rule'),
          ]),
        if (card.commonErrors.isNotEmpty)
          _Section(l10n.helpSectionCommonErrors, [
            for (final error in card.commonErrors) _ErrorEntry(error: error),
          ]),
        if (card.examples.isNotEmpty) _ExamplesSection(examples: card.examples),
      ],
    );
  }
}

final class _ExamplesSection extends StatelessWidget {
  final List<HelpExample> examples;

  const _ExamplesSection({required this.examples});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heading = examples.length == 1
        ? l10n.helpSectionExample
        : l10n.helpSectionExamples;
    return _Section(heading, [
      for (final example in examples) _ExampleEntry(example: example),
    ]);
  }
}

final class _ExampleEntry extends StatelessWidget {
  final HelpExample example;

  const _ExampleEntry({required this.example});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (example.kind == HelpExampleKind.diagnostic)
          AppText(
            l10n.helpExampleDiagnostic,
            variant: AppTextVariant.caption,
            color: theme.colors.severities.warning.fg,
          ),
        _ProgramBlock(program: example.program),
        _Prose(example.note),
      ],
    );
  }
}

final class _ErrorEntry extends StatelessWidget {
  final HelpCommonError error;

  const _ErrorEntry({required this.error});

  @override
  Widget build(BuildContext context) {
    final program = error.program;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Prose('• ${error.text}'),
        if (program != null) _ProgramBlock(program: program),
      ],
    );
  }
}

final class _ProgramBlock extends StatelessWidget {
  final HelpProgram program;

  const _ProgramBlock({required this.program});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final output = program.output;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpCodeView(
            source: program.source,
            highlightSpans: program.highlightSpans,
          ),
          if (output != null) ...[
            const SizedBox(height: SpacingTokens.space1),
            AppText(l10n.helpExampleOutput, variant: AppTextVariant.caption),
            HelpCodeView(source: output),
          ],
        ],
      ),
    );
  }
}

final class _PartRow extends StatelessWidget {
  final HelpPart part;

  const _PartRow({required this.part});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (part.kind == HelpPartKind.slot)
            HelpSlotChip(label: part.name)
          else
            AppText(
              part.name,
              variant: AppTextVariant.codeCaption,
              color: theme.syntax.keywordStructured,
            ),
          _Prose(part.text),
        ],
      ),
    );
  }
}

final class _Prose extends StatelessWidget {
  final String text;

  const _Prose(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(text, variant: AppTextVariant.bodySmall);
  }
}

final class _Section extends StatelessWidget {
  final String heading;
  final List<Widget> children;

  const _Section(this.heading, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: AppText(heading, variant: AppTextVariant.label),
          ),
          const SizedBox(height: SpacingTokens.space1),
          ...children,
        ],
      ),
    );
  }
}
