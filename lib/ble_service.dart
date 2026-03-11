import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// BLE only works on Android/iOS, not Chrome
// This service safely does nothing on web

class BleService extends ChangeNotifier {
  bool _connected = false;
  bool _scanning = false;
  String _status = 'Not connected';

  VoidCallback? onAlertReceived;

  bool get connected => _connected;
  bool get scanning => _scanning;
  String get status => _status;

  void _setStatus(String s) {
    _status = s;
    notifyListeners();
  }

  Future<void> startScan() async {
    if (kIsWeb) {
      _setStatus('BLE not available on web');
      return;
    }
    // Android/iOS BLE scanning goes here later
    _scanning = true;
    _setStatus('Scanning for device...');
    notifyListeners();

    // Simulate timeout for now
    await Future.delayed(const Duration(seconds: 10));
    if (!_connected) {
      _scanning = false;
      _setStatus('Device not found nearby');
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _connected = false;
    _setStatus('Disconnected');
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
