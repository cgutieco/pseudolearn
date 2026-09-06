import 'package:flutter/material.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import 'app_color_scheme.dart';
import 'app_component_themes.dart';
import 'tokens/color_semantic.dart';
import 'tokens/editor_metrics.dart';
import 'tokens/elevation.dart';
import 'tokens/syntax_colors.dart';
import 'tokens/typography.dart';

final class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final AppSemanticColors colors;
  final AppSyntaxColors syntax;
  final AppTypography typography;
  final AppElevation elevation;
  final EditorColors editor;
  final bool isDark;

  const AppThemeExtension({
    required this.colors,
    required this.syntax,
    required this.typography,
    required this.elevation,
    required this.editor,
    required this.isDark,
  });

  const AppThemeExtension.light({
    this.typography = const AppTypography.compact(),
  })  : colors = const AppSemanticColors.light(),
        syntax = const AppSyntaxColors.light(),
        elevation = const AppElevation.light(),
        editor = const EditorColors.light(),
        isDark = false;

  const AppThemeExtension.dark({
    this.typography = const AppTypography.compact(),
  })  : colors = const AppSemanticColors.dark(),
        syntax = const AppSyntaxColors.dark(),
        elevation = const AppElevation.dark(),
        editor = const EditorColors.dark(),
        isDark = true;

  @override
  AppThemeExtension copyWith({
    AppSemanticColors? colors,
    AppSyntaxColors? syntax,
    AppTypography? typography,
    AppElevation? elevation,
    EditorColors? editor,
    bool? isDark,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      syntax: syntax ?? this.syntax,
      typography: typography ?? this.typography,
      elevation: elevation ?? this.elevation,
      editor: editor ?? this.editor,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      colors: AppSemanticColors.lerp(colors, other.colors, t),
      syntax: t < 0.5 ? syntax : other.syntax,
      typography: t < 0.5 ? typography : other.typography,
      elevation: t < 0.5 ? elevation : other.elevation,
      editor: t < 0.5 ? editor : other.editor,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  static AppThemeExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<AppThemeExtension>();
    assert(
        extension != null, 'AppThemeExtension missing from the current Theme');
    return extension!;
  }
}

final class AppScrollBehavior extends ScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final isCompact =
        DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;
    return isCompact
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

final class AppUniformPageTransitionsTheme extends PageTransitionsTheme {
  const AppUniformPageTransitionsTheme();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
      route!,
      context!,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

final class AppTheme {
  static const PageTransitionsTheme pageTransitions =
      AppUniformPageTransitionsTheme();

  static ThemeData light({
    AppTypography typography = const AppTypography.compact(),
  }) {
    const semantic = AppSemanticColors.light();
    return _themeFrom(
      semantic: semantic,
      brightness: Brightness.light,
      extension: AppThemeExtension.light(typography: typography),
    );
  }

  static ThemeData dark({
    AppTypography typography = const AppTypography.compact(),
  }) {
    const semantic = AppSemanticColors.dark();
    return _themeFrom(
      semantic: semantic,
      brightness: Brightness.dark,
      extension: AppThemeExtension.dark(typography: typography),
    );
  }
}

ThemeData _themeFrom({
  required AppSemanticColors semantic,
  required Brightness brightness,
  required AppThemeExtension extension,
}) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: AppTheme.pageTransitions,
    scaffoldBackgroundColor: semantic.surfaces.canvas,
    canvasColor: semantic.surfaces.canvas,
    splashFactory: NoSplash.splashFactory,
    fontFamily: TypographyTokens.familyFor(AppFontRole.ui),
    fontFamilyFallback: TypographyTokens.fallbacksFor(AppFontRole.ui),
    colorScheme: buildAppColorScheme(semantic, brightness),
    navigationRailTheme: buildNavigationRailTheme(semantic),
    navigationBarTheme: buildNavigationBarTheme(semantic),
    dialogTheme: buildDialogTheme(semantic),
    inputDecorationTheme: buildInputDecorationTheme(semantic),
    cardTheme: buildCardTheme(semantic),
    dividerTheme: buildDividerTheme(semantic),
    tooltipTheme: buildTooltipTheme(semantic),
    scrollbarTheme: buildScrollbarTheme(semantic),
    snackBarTheme: buildSnackBarTheme(semantic),
    popupMenuTheme: buildPopupMenuTheme(semantic),
    progressIndicatorTheme: buildProgressIndicatorTheme(semantic),
    iconTheme: buildIconTheme(semantic),
    extensions: <ThemeExtension<dynamic>>[extension],
  );
}
