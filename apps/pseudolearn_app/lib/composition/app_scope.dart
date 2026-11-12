import 'package:go_router/go_router.dart';
import '../application/agent/screen_context_board.dart';
import '../application/settings/preference_updates.dart';
import '../domain/ports/app_navigator.dart';
import 'go_router_app_navigator.dart';

final class AppScope {
  final ScreenContextBoard board;
  final AppNavigator navigator;
  final PreferenceUpdates updates;

  AppScope({required this.board, required this.navigator}) : updates = PreferenceUpdates();

  factory AppScope.withRouter(GoRouter Function() router) =>
      AppScope(board: ScreenContextBoard(), navigator: GoRouterAppNavigator(router));

  factory AppScope.detached() =>
      AppScope(board: ScreenContextBoard(), navigator: const _DetachedNavigator());
}

final class _DetachedNavigator implements AppNavigator {
  const _DetachedNavigator();

  @override
  bool canNavigate(String location) => false;

  @override
  void navigate(String location) {}
}
