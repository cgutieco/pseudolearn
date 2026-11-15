import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/spacing.dart';
import 'app_card_surface.dart';

double _paddingFor(DeviceClass deviceClass, bool isNested) =>
    (deviceClass == DeviceClass.expanded && isNested) ? SpacingTokens.space5 : SpacingTokens.space4;

final class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isNested;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.isNested = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

final class _AppCardState extends State<AppCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  void _setHovered(bool value) => setState(() => _hovered = value);

  void _setPressed(bool value) => setState(() => _pressed = value);

  void _setFocused(bool value) => setState(() => _focused = value);

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final padding = canvas.scaled(_paddingFor(canvas.deviceClass, widget.isNested));

    return Semantics(
      button: widget.onTap != null,
      child: Focus(
        canRequestFocus: widget.onTap != null,
        onFocusChange: _setFocused,
        child: MouseRegion(
          cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
            onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
            onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
            onTap: widget.onTap,
            child: AppCardSurface(
              padding: EdgeInsets.all(padding),
              elevated: _hovered && !_pressed,
              focused: _focused,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
