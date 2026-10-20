import 'package:flutter/material.dart';
import '../../../domain/model/completion/completion_item.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'completion_detail_label.dart';

final class EditorCompletionPopup extends StatelessWidget {
  final List<CompletionItem> candidates;
  final int selectedIndex;
  final ValueChanged<CompletionItem> onSelected;

  const EditorCompletionPopup({
    super.key,
    required this.candidates,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.editorCompletionListLabel,
      container: true,
      child: _PopupFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < candidates.length; index++)
              _CompletionRow(
                item: candidates[index],
                isSelected: index == selectedIndex,
                onTap: () => onSelected(candidates[index]),
              ),
          ],
        ),
      ),
    );
  }
}

final class _PopupFrame extends StatelessWidget {
  final Widget child;

  const _PopupFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Material(
      elevation: SpacingTokens.space1,
      color: theme.colors.surfaces.defaultSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        side: BorderSide(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: SizedBox(
        width: ComponentMetricsTokens.editorCompletionPopupWidth,
        child: child,
      ),
    );
  }
}

final class _CompletionRow extends StatelessWidget {
  final CompletionItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompletionRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: ComponentMetricsTokens.editorCompletionRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        color: isSelected ? theme.colors.surfaces.brandSubtle : null,
        child: Row(
          children: [
            AppText(item.label, variant: AppTextVariant.codeInline),
            const SizedBox(width: SpacingTokens.space2),
            Expanded(child: _RowDetail(item: item)),
          ],
        ),
      ),
    );
  }
}

final class _RowDetail extends StatelessWidget {
  final CompletionItem item;

  const _RowDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final detail = localizedCompletionDetail(
      AppLocalizations.of(context)!,
      item,
    );
    return AppText(
      detail ?? '',
      variant: AppTextVariant.caption,
      color: theme.colors.text.tertiary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
