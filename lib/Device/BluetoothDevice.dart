import 'package:data_dashboard/Device/Device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as bluetooth;

class BluetoothDevice extends Device {
  late bluetooth.FlutterBluePlus _flutterBlue;
  late bluetooth.BluetoothDevice _device;
  bluetooth.BluetoothCharacteristic? _characteristics;
  String channel;

  late Stream<List<int>> _stream;

  BluetoothDevice(this._device, this.channel) {
    _flutterBlue = bluetooth.FlutterBluePlus.instance;
  }

  @override
  Future<void> connect() async {
    try {
      print("Connecting to the bluetooth device...");
      await _device.connect();
      List<bluetooth.BluetoothService> services = await _device.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((element) {
          if (element.uuid.toString().contains(channel)) {
            _characteristics = element;
            _stream = _characteristics!.value;
            print(_characteristics);
            return;
          }
        });
      });
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
  Stream<String> readData() {
    try {
      _characteristics!.setNotifyValue(true);
      return _stream.map((event) => String.fromCharCodes(event));
    } catch (e) {
      print("Failed to read data from the bluetooth device: $e");
    }
    return Stream.empty();
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
    return _device.name;
  }
}
