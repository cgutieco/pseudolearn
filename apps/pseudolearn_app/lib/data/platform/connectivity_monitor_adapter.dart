import 'dart:async';
import 'dart:io';
import '../../domain/ports/connectivity_monitor.dart';

final class ConnectivityMonitorAdapter implements ConnectivityMonitor {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _pollingTimer;
  bool? _lastStatus;

  ConnectivityMonitorAdapter({int pollIntervalSeconds = 15}) {
    final interval = DateTime.fromMillisecondsSinceEpoch(pollIntervalSeconds * 1000)
        .difference(DateTime.fromMillisecondsSinceEpoch(0));
    _pollingTimer = Timer.periodic(interval, (_) => checkAndEmit());
    checkAndEmit();
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async => _checkConnectivity();

  Future<void> checkAndEmit() async {
    final status = await _checkConnectivity();
    if (status != _lastStatus) {
      _lastStatus = status;
      if (!_controller.isClosed) {
        _controller.add(status);
      }
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final timeout = DateTime.fromMillisecondsSinceEpoch(3000)
          .difference(DateTime.fromMillisecondsSinceEpoch(0));
      final lookup = await InternetAddress.lookup('dns.google').timeout(timeout);
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _controller.close();
  }
}
