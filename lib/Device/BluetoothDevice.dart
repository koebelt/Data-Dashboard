import 'package:data_dashboard/Device/Device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as bluetooth;

class BluetoothDevice extends Device {
  final bluetooth.BluetoothDevice _device;
  bluetooth.BluetoothCharacteristic? _characteristic;

  BluetoothDevice(this._device);

  void setCharacteristic(bluetooth.BluetoothCharacteristic characteristic) {
    _characteristic = characteristic;
  }

  @override
  Future<void> connect() async {
    try {
      print("Connecting to the bluetooth device...");
      await _device.connect();
    } catch (e) {
      print("Failed to connect to the bluetooth device: $e");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _device.disconnect();
    } catch (e) {
      print("Failed to disconnect from the bluetooth device: $e");
    }
  }

  @override
  Stream<List<int>> readData() {
    try {
      if (_characteristic == null) {
        return const Stream.empty();
      }
      return _characteristic!.lastValueStream;
    } catch (e) {
      print("Failed to read data from the bluetooth device: $e");
    }
    return const Stream.empty();
  }

  @override
  void writeData(Uint8List data) {
    try {} catch (e) {
      print("Failed to write data to the bluetooth device: $e");
    }
  }

  @override
  String getType() {
    return "Bluetooth";
  }

  @override
  String getName() {
    return _device.platformName;
  }
}
