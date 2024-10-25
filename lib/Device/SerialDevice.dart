import 'package:data_dashboard/Device/Device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialDevice extends Device {
  late SerialPort _serialPort;
  final String _portAddress;
  final int _baudrate;
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
      _serialPort.close();
    } catch (e) {
      print("Failed to disconnect from the serial device: $e");
    }
  }

  @override
  Stream<List<int>> readData() {
    try {
      reader = SerialPortReader(_serialPort);
      return reader.stream;
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
