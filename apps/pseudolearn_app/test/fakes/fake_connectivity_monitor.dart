import 'dart:async';
import 'package:pseudolearn_app/domain/ports/connectivity_monitor.dart';

final class FakeConnectivityMonitor implements ConnectivityMonitor {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _connected;

  FakeConnectivityMonitor({bool initialConnected = true})
      : _connected = initialConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async => _connected;

  void setConnected(bool connected) {
    if (_connected != connected) {
      _connected = connected;
      _controller.add(connected);
    }
  }

  void dispose() {
    _controller.close();
  }
}
