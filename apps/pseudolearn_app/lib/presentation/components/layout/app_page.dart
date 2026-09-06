import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../button/app_button.dart';
import '../button/app_icon_button.dart';
import '../typography/app_text.dart';
import 'app_content_column.dart';

final class AppPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? action;
  final Widget? filter;
  final ContentMeasure measure;
  final VoidCallback? onBack;
  final String? backSemanticLabel;

  const AppPage({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.filter,
    this.measure = ContentMeasure.wide,
    this.onBack,
    this.backSemanticLabel,
  }) : assert(
          onBack == null || backSemanticLabel != null,
          'backSemanticLabel is required when onBack is given',
        );

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return SafeArea(
      child: AppContentColumn(
        measure: measure,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: canvas.scaled(SpacingTokens.space6)),
            _PageHeading(page: this),
            if (filter != null) ...[
              SizedBox(height: canvas.scaled(SpacingTokens.space4)),
              filter!,
            ],
            SizedBox(height: canvas.scaled(SpacingTokens.space5)),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

final class _PageHeading extends StatelessWidget {
  final AppPage page;

  const _PageHeading({required this.page});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (page.onBack != null) ...[
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: page.backSemanticLabel!,
            variant: AppButtonVariant.tertiary,
            onPressed: page.onBack,
          ),
          SizedBox(width: canvas.scaled(SpacingTokens.space2)),
        ],
        Expanded(child: _HeadingTitle(title: page.title)),
        if (page.action != null) ...[
          SizedBox(width: canvas.scaled(SpacingTokens.space4)),
          page.action!,
        ],
      ],
    );
  }
}

final class _HeadingTitle extends StatelessWidget {
  final String title;

  const _HeadingTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppText(
      title,
      variant: AppTextVariant.heading1,
      color: AppThemeExtension.of(context).colors.text.primary,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
