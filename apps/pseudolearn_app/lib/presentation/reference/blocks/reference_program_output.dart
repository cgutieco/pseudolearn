import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_program.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class ReferenceProgramOutput extends StatelessWidget {
  final ReferenceProgram program;

  const ReferenceProgramOutput({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final output = program.output.trimRight();
    return Container(
      color: theme.colors.surfaces.editor,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            l10n.referenceOutput,
            variant: AppTextVariant.overline,
            color: theme.colors.text.tertiary,
          ),
          const SizedBox(height: SpacingTokens.space1),
          ReferenceOutputText(
            text: output.isEmpty ? l10n.referenceNoOutput : output,
          ),
          ReferenceTerminationText(termination: program.termination),
          for (final diagnostic in program.diagnostics)
            ReferenceDiagnosticLine(diagnostic: diagnostic),
        ],
      ),
    );
  }
}

final class ReferenceTerminationText extends StatelessWidget {
  final String termination;

  const ReferenceTerminationText({super.key, required this.termination});

  @override
  Widget build(BuildContext context) {
    return AppText(
      terminationLabel(termination, AppLocalizations.of(context)!),
      variant: AppTextVariant.caption,
      color: AppThemeExtension.of(context).colors.text.tertiary,
    );
  }
}

final class ReferenceOutputText extends StatelessWidget {
  final String text;

  const ReferenceOutputText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: AppText(
        text,
        variant: AppTextVariant.codeCaption,
        color: theme.colors.text.primary,
      ),
    );
  }
}

final class ReferenceDiagnosticLine extends StatelessWidget {
  final ReferenceDiagnostic diagnostic;

  const ReferenceDiagnosticLine({super.key, required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final color = diagnostic.severity == 'error'
        ? theme.colors.severities.error.fg
        : theme.colors.severities.warning.fg;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space1),
      child: AppText(
        '${diagnostic.line}:${diagnostic.column} ${diagnostic.message} [${diagnostic.code}]',
        variant: AppTextVariant.codeCaption,
        color: color,
      ),
    );
  }
}

String terminationLabel(String termination, AppLocalizations l10n) =>
    switch (termination) {
      'completed' => l10n.referenceTerminationCompleted,
      'failed' => l10n.referenceTerminationFailed,
      'rejected' => l10n.referenceTerminationRejected,
      _ => l10n.referenceTerminationOther,
    };
