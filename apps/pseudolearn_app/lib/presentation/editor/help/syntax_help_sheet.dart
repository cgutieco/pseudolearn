import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/help/syntax_help_cubit.dart';
import '../../../application/editor/help/syntax_help_state.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'syntax_help_body.dart';

void showSyntaxHelpSheet(BuildContext context) {
  final cubit = context.read<SyntaxHelpCubit>();
  if (cubit.state.visibleResult == null) return;
  final theme = AppThemeExtension.of(context);
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: theme.colors.surfaces.overlay,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.radiusXl),
      ),
    ),
    builder: (_) => BlocProvider<SyntaxHelpCubit>.value(
      value: cubit,
      child: const SyntaxHelpSheet(),
    ),
  ).whenComplete(cubit.dismiss);
}

final class SyntaxHelpSheet extends StatelessWidget {
  const SyntaxHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: l10n.helpPanelLabel,
      child: SafeArea(
        child: BlocBuilder<SyntaxHelpCubit, SyntaxHelpState>(
          builder: (context, state) {
            final result = state.visibleResult;
            if (result == null) return const SizedBox.shrink();
            return _SheetBody(result: result);
          },
        ),
      ),
    );
  }
}

final class _SheetBody extends StatelessWidget {
  final HelpQueryResult result;

  const _SheetBody({required this.result});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SheetHeader(),
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: SpacingTokens.space4,
            right: SpacingTokens.space4,
            bottom: SpacingTokens.space4,
          ),
          child: SyntaxHelpBody(result: result),
        ),
      ),
    ],
  );
}

final class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.space4,
        right: SpacingTokens.space1,
        top: SpacingTokens.space1,
      ),
      child: Row(
        children: [
          const Expanded(child: _SheetTitle()),
          AppIconButton(
            icon: Icons.close,
            semanticLabel: l10n.helpClose,
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

final class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: AppText(
      AppLocalizations.of(context)!.helpPanelLabel,
      variant: AppTextVariant.label,
      color: AppThemeExtension.of(context).colors.text.secondary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
