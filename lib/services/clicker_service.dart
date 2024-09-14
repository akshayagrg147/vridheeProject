import 'package:flutter_clicker_sdk/flutter_clicker_sdk.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

class FlutterClickerService {
  // Private constructor
  FlutterClickerService._privateConstructor();

  // Singleton instance
  static final FlutterClickerService _instance = FlutterClickerService._privateConstructor();

  // Public getter for the singleton instance
  static FlutterClickerService get instance => _instance;

  // Set the scan mode (default to Bluetooth)
  void setClickerScanMode(ClickerScanMode mode) {
    FlutterClickerSdk.setClickerScanMode(mode: mode);
  }

  // Check if clicker scanning is available
  Future<bool> isClickerScanningAvailable() async {
    return await FlutterClickerSdk.isClickerScanningAvailable();
  }

  // Start scanning for clickers
  void startClickerScanning() {
    FlutterClickerSdk.startClickerScanning();
  }

  // Stop scanning for clickers
  void stopClickerScanning() {
    FlutterClickerSdk.stopClickerScanning();
  }

  // Listen to the clicker scan stream
  Stream<ClickerData> get clickerScanStream => FlutterClickerSdk.clickerScanStream;

  // Start clicker registration (for dongle mode)
  void startClickerRegistration(int registrationKey) {
    FlutterClickerSdk.startClickerRegistration(registrationKey: registrationKey);
  }

  // Stop clicker registration (for dongle mode)
  void stopClickerRegistration() {
    FlutterClickerSdk.stopClickerRegistration();
  }

  // Get current scan mode
  Future<ClickerScanMode> getClickerScanMode() async {
    return FlutterClickerSdk.getClickerScanMode();
  }
}