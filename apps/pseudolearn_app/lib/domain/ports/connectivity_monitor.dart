abstract interface class ConnectivityMonitor {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isConnected;
}
