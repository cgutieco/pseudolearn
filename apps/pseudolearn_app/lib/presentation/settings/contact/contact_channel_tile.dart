import 'package:flutter/material.dart';
import '../../components/button/app_copy_button.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/card_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class ContactChannelTile extends StatelessWidget {
  final String item;

  const ContactChannelTile({super.key, required this.item});

  IconData _iconFor(String value) {
    if (value.contains('@')) return Icons.mail_outline;
    if (value.contains('/contact')) return Icons.support_agent_outlined;
    return Icons.language_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);
    final colonIndex = item.indexOf(':');
    final label = colonIndex != -1 ? item.substring(0, colonIndex).trim() : item;
    final value = colonIndex != -1 ? item.substring(colonIndex + 1).trim() : '';

    return Container(
      margin: EdgeInsets.only(bottom: canvas.scaled(SpacingTokens.space3)),
      padding: EdgeInsets.symmetric(
        horizontal: canvas.scaled(SpacingTokens.space4),
        vertical: canvas.scaled(SpacingTokens.space3),
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: _TileRow(
        icon: _iconFor(value),
        label: label,
        value: value,
      ),
    );
  }
}

final class _TileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);

    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colors.text.link),
        SizedBox(width: canvas.scaled(SpacingTokens.space3)),
        Expanded(child: _TileInfo(label: label, value: value)),
        if (value.isNotEmpty) AppCopyButton(textToCopy: value),
      ],
    );
  }
}

final class _TileInfo extends StatelessWidget {
  final String label;
  final String value;

  const _TileInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, variant: AppTextVariant.caption, color: theme.colors.text.secondary),
        SizedBox(height: canvas.scaled(SpacingTokens.space1)),
        AppText(value, variant: AppTextVariant.bodyDefault, color: theme.colors.text.primary),
      ],
    );
  }
}
