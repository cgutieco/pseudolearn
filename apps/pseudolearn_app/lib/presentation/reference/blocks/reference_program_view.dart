import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_edition.dart';
import '../../../domain/model/reference/reference_program.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_code_pill.dart';
import '../reference_program_launcher.dart';
import 'reference_program_output.dart';

final class ReferenceProgramView extends StatelessWidget {
  final ReferenceProgram program;
  final ReferenceEdition edition;

  const ReferenceProgramView({
    super.key,
    required this.program,
    required this.edition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusLg),
        border: Border.all(color: theme.colors.borders.defaultBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReferenceProgramHeader(program: program, edition: edition),
          ReferenceProgramLines(program: program),
          if (program.executed) ReferenceProgramOutput(program: program),
        ],
      ),
    );
  }
}

final class ReferenceProgramHeader extends StatelessWidget {
  final ReferenceProgram program;
  final ReferenceEdition edition;

  const ReferenceProgramHeader({
    super.key,
    required this.program,
    required this.edition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: theme.colors.surfaces.subtle,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space1,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: SpacingTokens.space2,
        children: [
          AppText(program.title, variant: AppTextVariant.label),
          if (program.executed) const ReferenceExecutedSeal(),
          TextButton(
            onPressed: () => launchReferenceProgram(
              context: context,
              program: program,
              edition: edition,
            ),
            child: Text(l10n.referenceTryInEditor),
          ),
        ],
      ),
    );
  }
}

final class ReferenceExecutedSeal extends StatelessWidget {
  const ReferenceExecutedSeal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return AppText(
      '✓ ${AppLocalizations.of(context)!.referenceExecutedSeal}',
      variant: AppTextVariant.caption,
      color: theme.colors.severities.success.fg,
    );
  }
}

final class ReferenceProgramLines extends StatelessWidget {
  final ReferenceProgram program;

  const ReferenceProgramLines({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final style = resolveAppTextStyle(
      context,
      AppTextVariant.codeEditor,
      color: theme.syntax.ink,
    );
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReferenceLineNumbers(count: program.lines.length, style: style),
          const SizedBox(width: SpacingTokens.space3),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(children: programSpans(program, theme)),
                style: style,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class ReferenceLineNumbers extends StatelessWidget {
  final int count;
  final TextStyle style;

  const ReferenceLineNumbers({
    super.key,
    required this.count,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final text = [for (var line = 1; line <= count; line++) '$line'].join('\n');
    return ExcludeSemantics(
      child: Text(
        text,
        style: style.copyWith(color: theme.colors.text.tertiary),
        textAlign: TextAlign.right,
      ),
    );
  }
}

List<InlineSpan> programSpans(
  ReferenceProgram program,
  AppThemeExtension theme,
) {
  final spans = <InlineSpan>[];
  for (final (index, line) in program.lines.indexed) {
    if (index > 0) spans.add(const TextSpan(text: '\n'));
    spans.addAll(referenceTokenSpans(line, theme));
  }
  return spans;
}
