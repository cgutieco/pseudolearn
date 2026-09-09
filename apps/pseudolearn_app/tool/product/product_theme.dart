import 'package:flutter/material.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/elevation.dart';

const Map<AppThemeMode, AppSemanticColors> productColors =
    <AppThemeMode, AppSemanticColors>{
  AppThemeMode.light: AppSemanticColors.light(),
  AppThemeMode.dark: AppSemanticColors.dark(),
};

const Map<AppThemeMode, AppElevation> productElevation =
    <AppThemeMode, AppElevation>{
  AppThemeMode.light: AppElevation.light(),
  AppThemeMode.dark: AppElevation.dark(),
};

final Map<AppThemeMode, ThemeData> productThemes = <AppThemeMode, ThemeData>{
  AppThemeMode.light: AppTheme.light(),
  AppThemeMode.dark: AppTheme.dark(),
};
