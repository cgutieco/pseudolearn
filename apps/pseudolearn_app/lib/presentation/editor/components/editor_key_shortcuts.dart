import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final class _IndentIntent extends Intent {
  const _IndentIntent();
}

final class _DedentIntent extends Intent {
  const _DedentIntent();
}

final class _ReleaseFocusIntent extends Intent {
  const _ReleaseFocusIntent();
}

const Map<ShortcutActivator, Intent> _editorShortcuts =
    <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.tab): _IndentIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true): _DedentIntent(),
  SingleActivator(LogicalKeyboardKey.escape): _ReleaseFocusIntent(),
};

final class EditorKeyShortcuts extends StatelessWidget {
  final VoidCallback onIndent;
  final VoidCallback onDedent;
  final VoidCallback onReleaseFocus;
  final Widget child;

  const EditorKeyShortcuts({
    super.key,
    required this.onIndent,
    required this.onDedent,
    required this.onReleaseFocus,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _editorShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _IndentIntent:
              CallbackAction<_IndentIntent>(onInvoke: (_) => onIndent()),
          _DedentIntent:
              CallbackAction<_DedentIntent>(onInvoke: (_) => onDedent()),
          _ReleaseFocusIntent: CallbackAction<_ReleaseFocusIntent>(
              onInvoke: (_) => onReleaseFocus()),
        },
        child: child,
      ),
    );
  }
}
