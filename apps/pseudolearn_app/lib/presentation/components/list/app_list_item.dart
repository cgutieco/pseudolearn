import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/list_item_metrics.dart';
import '../typography/app_text.dart';

enum AppListItemTrailingKind { none, chevron, value, check }

Color _backgroundFor(AppThemeExtension theme, bool pressed, bool hovered) {
  final tertiary = theme.colors.actions.tertiary;
  if (pressed) return tertiary.bgPressed;
  if (hovered) return tertiary.bgHover;
  return tertiary.bgDefault;
}

final class AppListItem extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool isActiveDestination;
  final AppListItemTrailingKind trailing;
  final String? trailingValueText;
  final bool selected;
  final VoidCallback? onTap;

  const AppListItem({
    super.key,
    this.icon,
    required this.label,
    this.isActiveDestination = false,
    this.trailing = AppListItemTrailingKind.none,
    this.trailingValueText,
    this.selected = false,
    this.onTap,
  }) : assert(
          trailing != AppListItemTrailingKind.value || trailingValueText != null,
          'trailingValueText is required when trailing is AppListItemTrailingKind.value',
        );

  @override
  State<AppListItem> createState() => _AppListItemState();
}

final class _AppListItemState extends State<AppListItem> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) => setState(() => _hovered = value);

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final background = _backgroundFor(theme, _pressed, _hovered);
    final isRadioRole = widget.trailing == AppListItemTrailingKind.check;

    return Semantics(
      button: widget.onTap != null && !isRadioRole,
      inMutuallyExclusiveGroup: isRadioRole,
      selected: widget.selected,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
          onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
          onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
          onTap: widget.onTap,
          child: _ListItemBody(item: widget, background: background),
        ),
      ),
    );
  }
}

final class _ListItemBody extends StatelessWidget {
  final AppListItem item;
  final Color background;

  const _ListItemBody({required this.item, required this.background});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);
    final iconColor = item.isActiveDestination ? theme.colors.text.link : theme.colors.text.secondary;

    return Container(
      color: background,
      height: ListItemMetricsTokens.height,
      padding: EdgeInsets.symmetric(horizontal: canvas.scaled(ListItemMetricsTokens.paddingHorizontal)),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: ListItemMetricsTokens.iconSize, color: iconColor),
            SizedBox(width: canvas.scaled(ListItemMetricsTokens.gapIconToLabel)),
          ],
          Expanded(child: _ListItemLabel(label: item.label)),
          if (item.trailing != AppListItemTrailingKind.none) ...[
            SizedBox(width: canvas.scaled(ListItemMetricsTokens.gapLabelToTrailing)),
            _ListItemTrailing(kind: item.trailing, valueText: item.trailingValueText),
          ],
        ],
      ),
    );
  }
}

final class _ListItemLabel extends StatelessWidget {
  final String label;

  const _ListItemLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppText(
      label,
      variant: AppTextVariant.bodyDefault,
      color: AppThemeExtension.of(context).colors.text.primary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

final class _ListItemTrailing extends StatelessWidget {
  final AppListItemTrailingKind kind;
  final String? valueText;

  const _ListItemTrailing({required this.kind, required this.valueText});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return switch (kind) {
      AppListItemTrailingKind.none => const SizedBox.shrink(),
      AppListItemTrailingKind.chevron => Icon(
          Icons.chevron_right,
          size: ListItemMetricsTokens.trailingChevronSize,
          color: theme.colors.text.tertiary,
        ),
      AppListItemTrailingKind.check =>
        Icon(Icons.check, size: ListItemMetricsTokens.trailingCheckSize, color: theme.colors.text.link),
      AppListItemTrailingKind.value => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: DesignCanvasScope.of(context).scaled(ListItemMetricsTokens.trailingValueMaxWidth),
          ),
          child: AppText(
            valueText!,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    };
  }
}
