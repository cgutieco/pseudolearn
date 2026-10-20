import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'editor_assist_geometry.dart';

final class EditorGhostText extends StatelessWidget {
  final String text;
  final EditorGhostTypography typography;

  const EditorGhostText({
    super.key,
    required this.text,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: typography.style.copyWith(color: theme.colors.text.tertiary),
          textScaler: typography.scaler,
          strutStyle: typography.strut,
          textHeightBehavior: typography.heightBehavior,
          textDirection: typography.direction,
          locale: typography.locale,
        ),
      ),
    );
  }
}
