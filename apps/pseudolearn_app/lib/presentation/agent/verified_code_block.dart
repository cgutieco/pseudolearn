import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/editor/editor_cubit.dart';
import '../../application/editor/editor_state.dart';
import '../../domain/model/agent/code_block.dart';
import '../components/button/app_button.dart';
import '../components/button/app_copy_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';

final class VerifiedCodeBlock extends StatelessWidget {
  final CheckedCodeBlock code;

  const VerifiedCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.space2),
      padding: const EdgeInsets.all(SpacingTokens.space2),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.editor,
        borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusMd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Badge(verdict: code.verdict),
          SelectableText(code.block.source, style: resolveAppTextStyle(context, AppTextVariant.codeEditor)),
          _Actions(code: code),
        ],
      ),
    );
  }
}

final class _Badge extends StatelessWidget {
  final CodeBlockVerdict verdict;

  const _Badge({required this.verdict});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    if (verdict == CodeBlockVerdict.notPseudoLearn) return const SizedBox.shrink();
    final verified = verdict == CodeBlockVerdict.verified;
    return Semantics(
      label: verified ? l10n.agentVerified : l10n.agentWithErrors,
      child: AppText(
        verified ? '✓ ${l10n.agentVerified}' : '! ${l10n.agentWithErrors}',
        variant: AppTextVariant.label,
        color: verified ? theme.colors.severities.success.fg : theme.colors.severities.error.fg,
      ),
    );
  }
}

final class _Actions extends StatelessWidget {
  final CheckedCodeBlock code;

  const _Actions({required this.code});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editor) => Wrap(
        spacing: SpacingTokens.space2,
        children: [
          AppCopyButton(textToCopy: code.block.source),
          if (code.canInsert)
            AppButton(
              key: const ValueKey('agent-insert-code'),
              label: l10n.agentInsertInEditor,
              variant: AppButtonVariant.secondary,
              onPressed: editor.document == null
                  ? null
                  : () => context.read<EditorCubit>().updateSourceCode(
                      '${editor.sourceCode.trimRight()}\n${code.block.source}',
                    ),
            ),
        ],
      ),
    );
  }
}
