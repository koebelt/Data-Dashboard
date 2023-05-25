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

      _serialPort.openReadWrite();
      _serialPort.config.baudRate = _baudrate;
      _serialPort.config.bits = 8;
      _serialPort.config.stopBits = 1;

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

// class DeviceReader {
//   // Define a stream controller to emit the received data
//   final StreamController<String> _dataStreamController =
//       StreamController<String>();
//   Stream<String> get dataStream => _dataStreamController.stream;

//   // Instance variables
//   Device _device;
//   bool _isReading = false;

//   // Constructor
//   DeviceReader(this._device);

//   // Start reading data
//   void startReading() {
//     _isReading = true;
//     _readData();
//   }

//   // Stop reading data
//   void stopReading() {
//     _isReading = false;
//   }

//   // Read data from the device
//   void _readData() {
//     while (_isReading) {
//       String receivedData = '';
//       while (!receivedData.contains('\n')) {
//         Uint8List newData = _device.readData(); // Read one byte at a time
//         receivedData += String.fromCharCodes(newData);
//       }
//       print(receivedData);
//       _dataStreamController.add(receivedData);
//     }
//   }
// }
