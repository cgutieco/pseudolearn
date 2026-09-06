import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import '../application/settings/settings_cubit.dart';
import '../application/settings/settings_state.dart';
import '../domain/model/settings/app_theme_mode.dart';
import '../domain/model/settings/ui_language_id.dart';
import '../presentation/l10n/generated/app_localizations.dart';
import '../presentation/routing/app_router.dart';
import '../presentation/shell/design_canvas.dart';
import '../presentation/theme/app_theme.dart';
import 'app_dependencies.dart';
import 'app_providers.dart';

const Map<AppThemeMode, ThemeMode> _themeModes = {
  AppThemeMode.system: ThemeMode.system,
  AppThemeMode.light: ThemeMode.light, AppThemeMode.dark: ThemeMode.dark,
};

const Map<UiLanguageId, Locale?> _locales = {
  UiLanguageId.system: null,
  UiLanguageId.spanish: Locale('es'),
  UiLanguageId.english: Locale('en'),
};

final class CubitScope extends StatelessWidget {
  final AppDependencies dependencies;
  final GoRouter router;

  CubitScope({
    super.key,
    required this.dependencies,
    GoRouter? router,
  }) : router = router ?? buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: buildAppProviders(dependencies),
      child: _CubitScopeApp(router: router),
    );
  }
}

final class _CubitScopeApp extends StatelessWidget {
  final GoRouter router;

  const _CubitScopeApp({required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.themeMode != curr.themeMode || prev.language != curr.language,
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeModes[state.themeMode] ?? ThemeMode.system,
          locale: _locales[state.language],
          scrollBehavior: const AppScrollBehavior(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
