import 'dart:ui';

enum AppFontRole { ui, code }

final class TypographyTokens {
  static const Map<AppFontRole, String?> bundledFamilies =
      <AppFontRole, String?>{
    AppFontRole.ui: 'IBMPlexSans',
    AppFontRole.code: 'IBMPlexMono',
  };

  static const Map<AppFontRole, List<String>> systemFallbacks =
      <AppFontRole, List<String>>{
    AppFontRole.ui: <String>[
      'SF Pro Text',
      'Segoe UI Variable',
      'Segoe UI',
      'Roboto',
      'Noto Sans'
    ],
    AppFontRole.code: <String>[
      'SF Mono',
      'Cascadia Mono',
      'Consolas',
      'Roboto Mono',
      'Noto Sans Mono'
    ],
  };

  static String? familyFor(AppFontRole role) => bundledFamilies[role];

  static List<String> fallbacksFor(AppFontRole role) => systemFallbacks[role]!;

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  static const double textScaleMin = 0.85;
  static const double textScaleMax = 2.00;
  static const double textScaleReflowThreshold = 1.30;
  static const double editorFontSizeMin = 11.0;
  static const double editorFontSizeMax = 24.0;
  static const double editorFontSizeStep = 1.0;
}

final class AppTextStyleSpec {
  final double fontSize;
  final double lineHeight;
  final FontWeight fontWeight;
  final double letterSpacing;
  final AppFontRole role;

  const AppTextStyleSpec({
    required this.fontSize,
    required this.lineHeight,
    required this.fontWeight,
    required this.letterSpacing,
    required this.role,
  });

  const AppTextStyleSpec.bold(this.fontSize, this.lineHeight,
      [double spacing = 0.0])
      : fontWeight = TypographyTokens.weightBold,
        letterSpacing = spacing,
        role = AppFontRole.ui;

  const AppTextStyleSpec.semi(this.fontSize, this.lineHeight,
      [double spacing = 0.0])
      : fontWeight = TypographyTokens.weightSemibold,
        letterSpacing = spacing,
        role = AppFontRole.ui;

  const AppTextStyleSpec.ui(this.fontSize, this.lineHeight,
      [double spacing = 0.0])
      : fontWeight = TypographyTokens.weightRegular,
        letterSpacing = spacing,
        role = AppFontRole.ui;

  const AppTextStyleSpec.code(this.fontSize, this.lineHeight)
      : fontWeight = TypographyTokens.weightRegular,
        letterSpacing = 0.0,
        role = AppFontRole.code;

  String? get fontFamily => TypographyTokens.familyFor(role);

  List<String> get fontFamilyFallback => TypographyTokens.fallbacksFor(role);

  double get height => lineHeight / fontSize;
}

final class AppTypography {
  final AppTextStyleSpec display;
  final AppTextStyleSpec heading1;
  final AppTextStyleSpec heading2;
  final AppTextStyleSpec heading3;
  final AppTextStyleSpec heading4;
  final AppTextStyleSpec bodyLarge;
  final AppTextStyleSpec bodyDefault;
  final AppTextStyleSpec bodySmall;
  final AppTextStyleSpec label;
  final AppTextStyleSpec caption;
  final AppTextStyleSpec overline;
  final AppTextStyleSpec codeEditor;
  final AppTextStyleSpec codeInline;
  final AppTextStyleSpec codeCaption;

  const AppTypography({
    required this.display,
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.heading4,
    required this.bodyLarge,
    required this.bodyDefault,
    required this.bodySmall,
    required this.label,
    required this.caption,
    required this.overline,
    required this.codeEditor,
    required this.codeInline,
    required this.codeCaption,
  });

  const AppTypography.compact()
      : display = const AppTextStyleSpec.bold(30, 36, -0.3),
        heading1 = const AppTextStyleSpec.bold(24, 30, -0.2),
        heading2 = const AppTextStyleSpec.semi(20, 26, -0.1),
        heading3 = const AppTextStyleSpec.semi(17, 23),
        heading4 = const AppTextStyleSpec.semi(15, 21, 0.1),
        bodyLarge = const AppTextStyleSpec.ui(17, 26),
        bodyDefault = const AppTextStyleSpec.ui(15, 23),
        bodySmall = const AppTextStyleSpec.ui(13, 20),
        label = const AppTextStyleSpec.semi(13, 16, 0.2),
        caption = const AppTextStyleSpec.ui(12, 16, 0.2),
        overline = const AppTextStyleSpec.bold(11, 14, 0.8),
        codeEditor = const AppTextStyleSpec.code(14, 22),
        codeInline = const AppTextStyleSpec.code(14, 23),
        codeCaption = const AppTextStyleSpec.code(12, 18);

  const AppTypography.medium()
      : display = const AppTextStyleSpec.bold(32, 38, -0.3),
        heading1 = const AppTextStyleSpec.bold(25, 32, -0.2),
        heading2 = const AppTextStyleSpec.semi(21, 28, -0.1),
        heading3 = const AppTextStyleSpec.semi(18, 24),
        heading4 = const AppTextStyleSpec.semi(16, 22, 0.1),
        bodyLarge = const AppTextStyleSpec.ui(17, 26),
        bodyDefault = const AppTextStyleSpec.ui(15, 23),
        bodySmall = const AppTextStyleSpec.ui(13, 20),
        label = const AppTextStyleSpec.semi(13, 16, 0.2),
        caption = const AppTextStyleSpec.ui(12, 16, 0.2),
        overline = const AppTextStyleSpec.bold(11, 14, 0.8),
        codeEditor = const AppTextStyleSpec.code(14, 22),
        codeInline = const AppTextStyleSpec.code(14, 23),
        codeCaption = const AppTextStyleSpec.code(12, 18);

  const AppTypography.expanded()
      : display = const AppTextStyleSpec.bold(32, 38, -0.3),
        heading1 = const AppTextStyleSpec.bold(22, 28, -0.2),
        heading2 = const AppTextStyleSpec.semi(19, 25, -0.1),
        heading3 = const AppTextStyleSpec.semi(16, 22),
        heading4 = const AppTextStyleSpec.semi(14, 20, 0.1),
        bodyLarge = const AppTextStyleSpec.ui(16, 24),
        bodyDefault = const AppTextStyleSpec.ui(14, 21),
        bodySmall = const AppTextStyleSpec.ui(13, 19),
        label = const AppTextStyleSpec.semi(13, 16, 0.2),
        caption = const AppTextStyleSpec.ui(12, 16, 0.2),
        overline = const AppTextStyleSpec.bold(11, 14, 0.8),
        codeEditor = const AppTextStyleSpec.code(13, 21),
        codeInline = const AppTextStyleSpec.code(13, 21),
        codeCaption = const AppTextStyleSpec.code(12, 18);
}
