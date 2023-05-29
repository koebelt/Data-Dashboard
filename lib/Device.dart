import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class Device {
  // Abstract method to connect to the device
  Future<void> connect();

  // Abstract method to disconnect from the device
  Future<void> disconnect();

  // Abstract method to read data from the device
  Stream<String> readData();

  // Abstract method to write data to the device
  void writeData(Uint8List data);

  String getType();

  String getName();
}

class SerialDevice extends Device {
  late SerialPort _serialPort;
  String _portAddress;
  int _baudrate;
  late SerialPortReader reader;

  SerialDevice(this._portAddress, this._baudrate) {
    SerialPort.availablePorts;
    _serialPort = SerialPort(_portAddress);
  }

  @override
  Future<void> connect() async {
    try {
      print("Connecting to the serial device...");

      _serialPort.open(mode: SerialPortMode.readWrite);
      _serialPort.config.baudRate = _baudrate;
      _serialPort.config.bits = 8;
      _serialPort.config.stopBits = 1;
      _serialPort.config.parity = SerialPortParity.none;
      _serialPort.config.setFlowControl(SerialPortFlowControl.none);
      // _serialPort.openReadWrite();

      print(_serialPort.config.baudRate);
    } catch (e) {
      print("Failed to connect to the serial device: $e");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      reader.close();
      await _serialPort.close();
    } catch (e) {
      print("Failed to disconnect from the serial device: $e");
    }
  }

  @override
  Stream<String> readData() {
    try {
      reader = SerialPortReader(_serialPort);
      return reader.stream.map((event) =>
          String.fromCharCodes(event).split('\n').length > 1
              ? String.fromCharCodes(event).split('\n')[1]
              : "0");
    } catch (e) {
      print("Failed to read data from the serial device: $e");
    }
    return Stream.empty();
  }

  @override
  void writeData(Uint8List data) {
    try {
      if (_serialPort.isOpen) {
        _serialPort.write(data);
      }
    } catch (e) {
      print("Failed to write data to the serial device: $e");
    }
  }

  @override
  String getType() {
    return "Serial";
  }

  @override
  String getName() {
    return _portAddress;
  }
}

class BlueToothDevice extends Device {
  late FlutterBluePlus _flutterBlue;
  late BluetoothDevice _device;
  BluetoothCharacteristic? _characteristics;
  String channel;

  late Stream<List<int>> _stream;

  BlueToothDevice(this._device, this.channel) {
    _flutterBlue = FlutterBluePlus.instance;
  }

  @override
  Future<void> connect() async {
    try {
      print("Connecting to the bluetooth device...");
      await _device.connect();
      List<BluetoothService> services = await _device.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((element) {
          if (element.uuid.toString().contains(channel)) {
            _characteristics = element;
            _stream = _characteristics!.value;
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
      return _stream.map((event) =>
          String.fromCharCodes(event).split('\n').length > 1
              ? String.fromCharCodes(event).split('\n')[1]
              : "0");
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
