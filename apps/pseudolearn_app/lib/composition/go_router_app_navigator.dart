import 'package:go_router/go_router.dart';
import '../domain/ports/app_navigator.dart';

final class GoRouterAppNavigator implements AppNavigator {
  static const List<String> branches = ['/biblioteca', '/conocimiento', '/progreso', '/ajustes'];

  final GoRouter Function() _router;

  const GoRouterAppNavigator(this._router);

  @override
  bool canNavigate(String location) {
    final path = Uri.tryParse(location)?.path ?? '';
    return branches.any((branch) => path == branch || path.startsWith('$branch/'));
  }

  @override
  void navigate(String location) => _router().go(location);
}
