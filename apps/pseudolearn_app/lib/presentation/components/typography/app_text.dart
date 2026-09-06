import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/typography.dart';

enum AppTextVariant {
  display,
  heading1,
  heading2,
  heading3,
  heading4,
  bodyLarge,
  bodyDefault,
  bodySmall,
  label,
  caption,
  overline,
  codeEditor,
  codeInline,
  codeCaption,
}

const Map<DeviceClass, AppTypography> _typographyByClass = <DeviceClass, AppTypography>{
  DeviceClass.compact: AppTypography.compact(),
  DeviceClass.medium: AppTypography.medium(),
  DeviceClass.expanded: AppTypography.expanded(),
};

const Set<AppTextVariant> _variantsFollowingSystemScale = <AppTextVariant>{
  AppTextVariant.display,
  AppTextVariant.heading1,
  AppTextVariant.heading2,
  AppTextVariant.heading3,
  AppTextVariant.heading4,
  AppTextVariant.bodyLarge,
  AppTextVariant.bodyDefault,
  AppTextVariant.bodySmall,
  AppTextVariant.label,
  AppTextVariant.caption,
  AppTextVariant.overline,
  AppTextVariant.codeInline,
};

AppTextStyleSpec _specFor(AppTypography typography, AppTextVariant variant) {
  return switch (variant) {
    AppTextVariant.display => typography.display,
    AppTextVariant.heading1 => typography.heading1,
    AppTextVariant.heading2 => typography.heading2,
    AppTextVariant.heading3 => typography.heading3,
    AppTextVariant.heading4 => typography.heading4,
    AppTextVariant.bodyLarge => typography.bodyLarge,
    AppTextVariant.bodyDefault => typography.bodyDefault,
    AppTextVariant.bodySmall => typography.bodySmall,
    AppTextVariant.label => typography.label,
    AppTextVariant.caption => typography.caption,
    AppTextVariant.overline => typography.overline,
    AppTextVariant.codeEditor => typography.codeEditor,
    AppTextVariant.codeInline => typography.codeInline,
    AppTextVariant.codeCaption => typography.codeCaption,
  };
}

int _overlineWordCount(String text) {
  var count = 0;
  var insideWord = false;
  for (final rune in text.runes) {
    final isWhitespace = rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D;
    if (isWhitespace) {
      insideWord = false;
    } else if (!insideWord) {
      insideWord = true;
      count++;
    }
  }
  return count;
}

TextStyle resolveAppTextStyle(BuildContext context, AppTextVariant variant, {Color? color}) {
  final deviceClass = DesignCanvasScope.of(context).deviceClass;
  final spec = _specFor(_typographyByClass[deviceClass]!, variant);
  return TextStyle(
    fontFamily: spec.fontFamily,
    fontFamilyFallback: spec.fontFamilyFallback,
    fontSize: spec.fontSize,
    height: spec.height,
    fontWeight: spec.fontWeight,
    letterSpacing: spec.letterSpacing,
    color: color,
    fontFeatures: variant == AppTextVariant.codeCaption
        ? const [FontFeature.tabularFigures()]
        : null,
  );
}

TextScaler? resolveAppTextScaler(AppTextVariant variant) =>
    _variantsFollowingSystemScale.contains(variant) ? null : TextScaler.noScaling;

final class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    required this.variant,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      variant != AppTextVariant.overline || _overlineWordCount(text) <= 3,
      'Overline text is limited to three words: "$text"',
    );

    final defaultColor = AppThemeExtension.of(context).colors.text.primary;

    return Text(
      text,
      style: resolveAppTextStyle(context, variant, color: color ?? defaultColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: resolveAppTextScaler(variant),
    );
  }
}
