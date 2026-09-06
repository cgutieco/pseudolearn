import 'package:go_router/go_router.dart';

void goToShellBranch(StatefulNavigationShell shell, int index) {
  shell.goBranch(index, initialLocation: index == shell.currentIndex);
}
