import 'package:flutter/material.dart';
import 'font_role_style.dart';
import 'tokens/border_metrics.dart';
import 'tokens/card_metrics.dart';
import 'tokens/color_primitives.dart';
import 'tokens/component_metrics.dart';
import 'tokens/color_semantic.dart';
import 'tokens/dialog_metrics.dart';
import 'tokens/field_metrics.dart';
import 'tokens/icon_metrics.dart';
import 'tokens/motion.dart';
import 'tokens/radii.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

NavigationRailThemeData buildNavigationRailTheme(AppSemanticColors semantic) {
  return NavigationRailThemeData(
    backgroundColor: semantic.surfaces.defaultSurface,
    indicatorColor: semantic.surfaces.brandSubtle,
    indicatorShape: const StadiumBorder(),
    selectedIconTheme: IconThemeData(
        color: semantic.text.link, size: IconMetricsTokens.iconMd),
    unselectedIconTheme: IconThemeData(
        color: semantic.text.secondary, size: IconMetricsTokens.iconMd),
    selectedLabelTextStyle:
        TextStyle(color: semantic.text.link, fontWeight: FontWeight.w600)
            .inRole(AppFontRole.ui),
    unselectedLabelTextStyle:
        TextStyle(color: semantic.text.secondary).inRole(AppFontRole.ui),
    useIndicator: true,
    minWidth: ComponentMetricsTokens.navRailWidth,
  );
}

NavigationBarThemeData buildNavigationBarTheme(AppSemanticColors semantic) {
  return NavigationBarThemeData(
    backgroundColor: semantic.surfaces.defaultSurface,
    surfaceTintColor: ColorPrimitives.transparent,
    indicatorColor: semantic.surfaces.brandSubtle,
    indicatorShape: const StadiumBorder(),
    elevation: 0,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: IconMetricsTokens.iconMd,
        color: states.contains(WidgetState.selected)
            ? semantic.text.link
            : semantic.text.secondary,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? semantic.text.link
            : semantic.text.secondary,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w500,
      ).inRole(AppFontRole.ui),
    ),
  );
}

DialogThemeData buildDialogTheme(AppSemanticColors semantic) {
  return DialogThemeData(
    backgroundColor: semantic.surfaces.raised,
    surfaceTintColor: ColorPrimitives.transparent,
    elevation: 0,
    barrierColor:
        semantic.surfaces.inverse.withValues(alpha: semantic.opacities.scrim),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DialogMetricsTokens.radius),
      side: BorderSide(
          color: semantic.borders.subtle,
          width: BorderMetricsTokens.widthHairline),
    ),
    constraints: const BoxConstraints(
      minWidth: DialogMetricsTokens.minWidth,
      maxWidth: DialogMetricsTokens.maxWidth,
    ),
  );
}

InputDecorationTheme buildInputDecorationTheme(AppSemanticColors semantic) {
  return InputDecorationTheme(
    filled: true,
    fillColor: semantic.surfaces.defaultSurface,
    hintStyle: TextStyle(color: semantic.text.tertiary).inRole(AppFontRole.ui),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FieldMetricsTokens.paddingHorizontal,
      vertical: FieldMetricsTokens.paddingVertical,
    ),
    border: _fieldBorder(
        semantic.borders.defaultBorder, BorderMetricsTokens.widthHairline),
    enabledBorder: _fieldBorder(
        semantic.borders.defaultBorder, BorderMetricsTokens.widthHairline),
    focusedBorder: _fieldBorder(
        semantic.borders.focus, BorderMetricsTokens.focusRingWidth),
    errorBorder: _fieldBorder(
        semantic.severities.error.border, BorderMetricsTokens.widthHairline),
    focusedErrorBorder: _fieldBorder(
        semantic.severities.error.border, BorderMetricsTokens.focusRingWidth),
    disabledBorder: _fieldBorder(
        semantic.borders.subtle, BorderMetricsTokens.widthHairline),
  );
}

OutlineInputBorder _fieldBorder(Color color, double width) {
  return OutlineInputBorder(
    borderRadius:
        const BorderRadius.all(Radius.circular(FieldMetricsTokens.radius)),
    borderSide: BorderSide(color: color, width: width),
  );
}

CardThemeData buildCardTheme(AppSemanticColors semantic) {
  return CardThemeData(
    color: semantic.surfaces.defaultSurface,
    surfaceTintColor: ColorPrimitives.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
      side: BorderSide(
          color: semantic.borders.defaultBorder,
          width: BorderMetricsTokens.widthHairline),
    ),
  );
}

DividerThemeData buildDividerTheme(AppSemanticColors semantic) {
  return DividerThemeData(
    color: semantic.borders.subtle,
    thickness: BorderMetricsTokens.widthHairline,
    space: BorderMetricsTokens.widthHairline,
  );
}

TooltipThemeData buildTooltipTheme(AppSemanticColors semantic) {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: semantic.surfaces.inverse,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
    ),
    textStyle: TextStyle(color: semantic.text.inverse).inRole(AppFontRole.ui),
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.space2,
      vertical: SpacingTokens.space1,
    ),
    waitDuration: MotionTokens.tooltipWait,
  );
}

ScrollbarThemeData buildScrollbarTheme(AppSemanticColors semantic) {
  return ScrollbarThemeData(
    thumbColor: WidgetStatePropertyAll(semantic.borders.strong),
    trackColor: const WidgetStatePropertyAll(Color(0x00000000)),
    radius: const Radius.circular(RadiusTokens.radiusFull),
    thickness: const WidgetStatePropertyAll(
        SpacingTokens.space1 + SpacingTokens.spaceHalf),
    crossAxisMargin: SpacingTokens.spaceHalf,
  );
}

SnackBarThemeData buildSnackBarTheme(AppSemanticColors semantic) {
  return SnackBarThemeData(
    backgroundColor: semantic.surfaces.inverse,
    contentTextStyle:
        TextStyle(color: semantic.text.inverse).inRole(AppFontRole.ui),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd)),
  );
}

PopupMenuThemeData buildPopupMenuTheme(AppSemanticColors semantic) {
  return PopupMenuThemeData(
    color: semantic.surfaces.raised,
    surfaceTintColor: ColorPrimitives.transparent,
    elevation: 0,
    textStyle: TextStyle(color: semantic.text.primary).inRole(AppFontRole.ui),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
      side: BorderSide(
          color: semantic.borders.subtle,
          width: BorderMetricsTokens.widthHairline),
    ),
  );
}

ProgressIndicatorThemeData buildProgressIndicatorTheme(
    AppSemanticColors semantic) {
  return ProgressIndicatorThemeData(
    color: semantic.actions.primary.bgDefault,
    linearTrackColor: semantic.surfaces.subtle,
    circularTrackColor: semantic.surfaces.subtle,
  );
}

IconThemeData buildIconTheme(AppSemanticColors semantic) {
  return IconThemeData(
      color: semantic.text.secondary, size: IconMetricsTokens.iconMd);
}
