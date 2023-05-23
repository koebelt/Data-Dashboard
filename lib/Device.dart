import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

abstract class Device {
  // Abstract method to connect to the device
  Future<void> connect();

  // Abstract method to disconnect from the device
  Future<void> disconnect();

  // Abstract method to read data from the device
  Uint8List readData();

  // Abstract method to write data to the device
  void writeData(Uint8List data);
}

class SerialDevice extends Device {
  late SerialPort _serialPort;
  String _portAddress;
  int _baudrate;

  SerialDevice(this._portAddress, this._baudrate);

  @override
  Future<void> connect() async {
    try {
      _serialPort = SerialPort(_portAddress);
      _serialPort.config.baudRate = _baudrate;
      _serialPort.openReadWrite();
    } catch (e) {
      print("Failed to connect to the serial device: $e");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _serialPort.close();
    } catch (e) {
      print("Failed to disconnect from the serial device: $e");
    }
  }

  @override
  Uint8List readData() {
    try {
      if (_serialPort.isOpen) {
        return _serialPort.read(1);
      }
    } catch (e) {
      print("Failed to read data from the serial device: $e");
    }
    return Uint8List(0);
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
}

class DeviceReader {
  // Define a stream controller to emit the received data
  final StreamController<String> _dataStreamController =
      StreamController<String>();
  Stream<String> get dataStream => _dataStreamController.stream;

  // Instance variables
  Device _device;
  bool _isReading = false;

  // Constructor
  DeviceReader(this._device);

  // Start reading data
  void startReading() {
    _isReading = true;
    _readData();
  }

  // Stop reading data
  void stopReading() {
    _isReading = false;
  }

  // Read data from the device
  void _readData() {
    while (_isReading) {
      String receivedData = '';
      while (!receivedData.contains('\n')) {
        Uint8List newData = _device.readData(); // Read one byte at a time
        receivedData += String.fromCharCodes(newData);
      }
      _dataStreamController.add(receivedData);
    }
  }
}
