import '../model/agent/screen_context_snapshot.dart';

abstract interface class ScreenContextSource {
  ScreenContextSnapshot snapshot();
  String fullText();
}
