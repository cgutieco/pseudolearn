import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/button_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/motion.dart';
import '../../theme/tokens/radii.dart';
import 'button_palette.dart';

final class AppCopyButton extends StatefulWidget {
  final String textToCopy;
  final VoidCallback? onCopied;

  const AppCopyButton({
    super.key,
    required this.textToCopy,
    this.onCopied,
  });

  @override
  State<AppCopyButton> createState() => _AppCopyButtonState();
}

final class _AppCopyButtonState extends State<AppCopyButton> {
  bool _isConfirmed = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    setState(() => _isConfirmed = true);
    if (widget.onCopied != null) {
      widget.onCopied!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);
    final minSize = canvas.scaled(ButtonMetricsTokens.buttonIconOnlyMinSize);

    final tooltip = _isConfirmed ? l10n.knowledgeDetailCopied : l10n.actionCopy;

    final child = _CopyButtonContent(
      isConfirmed: _isConfirmed,
      tooltip: tooltip,
      minSize: minSize,
      theme: theme,
      onPressed: _handleCopy,
    );

    if (!_isConfirmed) return child;

    return TweenAnimationBuilder<double>(
      key: ValueKey(_isConfirmed),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: ComponentMetricsTokens.buttonCopyConfirmedDuration,
      onEnd: () {
        if (mounted) setState(() => _isConfirmed = false);
      },
      builder: (context, value, _) => child,
    );
  }
}

final class _CopyButtonContent extends StatelessWidget {
  final bool isConfirmed;
  final String tooltip;
  final double minSize;
  final AppThemeExtension theme;
  final VoidCallback onPressed;

  const _CopyButtonContent({
    required this.isConfirmed,
    required this.tooltip,
    required this.minSize,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ButtonPalette.forVariant(
      theme.colors.actions,
      AppButtonVariant.tertiary,
      destructive: false,
      isDark: theme.isDark,
    );

    final iconColor = isConfirmed
        ? theme.colors.severities.success.fg
        : theme.colors.text.secondary;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        style: _copyButtonStyle(palette, iconColor, minSize),
        icon: AnimatedSwitcher(
          duration: MotionTokens.motionFast,
          child: Icon(
            isConfirmed ? Icons.check_rounded : Icons.copy_rounded,
            key: ValueKey(isConfirmed),
            size: IconMetricsTokens.iconSm,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

ButtonStyle _copyButtonStyle(ButtonPalette palette, Color iconColor, double minSize) {
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size.square(minSize)),
    fixedSize: WidgetStatePropertyAll(Size.square(minSize)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.radiusSm)),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(palette.background),
    foregroundColor: WidgetStatePropertyAll(iconColor),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
  );
}
