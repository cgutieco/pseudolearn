import 'package:flutter/material.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';

final class ReferenceLinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ReferenceLinkText({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap,
        child: AppText(
          text,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.link,
        ),
      ),
    );
  }
}
