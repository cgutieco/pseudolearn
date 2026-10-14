import 'package:pseudolearn_core/pseudolearn_core.dart';

final class CountingObserver implements ExecutionObserver {
  int events = 0;

  @override
  void onEvent(ExecutionEvent event) {
    events++;
  }
}
