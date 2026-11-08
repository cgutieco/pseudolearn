import '../../domain/model/agent/screen_context_snapshot.dart';
import '../../domain/ports/screen_context_source.dart';

final class ScreenContextBoard implements ScreenContextSource {
  ScreenContextSnapshot _snapshot = const ScreenContextSnapshot.unknown();
  String Function() _fullText = _nothing;

  static String _nothing() => '';

  void publish(ScreenContextSnapshot snapshot, {String Function()? fullText}) {
    _snapshot = snapshot;
    _fullText = fullText ?? _nothing;
  }

  void withdraw(String screen) {
    if (_snapshot.screen != screen) return;
    _snapshot = const ScreenContextSnapshot.unknown();
    _fullText = _nothing;
  }

  @override
  ScreenContextSnapshot snapshot() => _snapshot;

  @override
  String fullText() {
    final text = _fullText();
    return text.length > 20000 ? text.substring(0, 20000) : text;
  }
}
