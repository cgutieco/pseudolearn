import 'dart:async';

final class ProgressUpdates {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void publish() => _controller.add(null);
}
