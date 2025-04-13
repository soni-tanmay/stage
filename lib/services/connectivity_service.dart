import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_connectionChanged);
  }

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _connectionChanged(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    _connectionStatusController.sink.add(isConnected);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
