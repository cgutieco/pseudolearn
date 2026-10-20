import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';

final class EditorGhostText extends StatelessWidget {
  final String text;

  const EditorGhostText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: resolveAppTextStyle(
            context,
            AppTextVariant.codeEditor,
            color: theme.colors.text.tertiary,
          ),
        ),
      ),
    );
  }
}
