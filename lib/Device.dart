import 'dart:async';
import 'dart:math';
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
      await _serialPort.close();
    } catch (e) {
      print("Failed to disconnect from the serial device: $e");
    }
  }

  @override
  Stream<String> readData() {
    try {
      reader = SerialPortReader(_serialPort);
      return reader.stream.map((event) => String.fromCharCodes(event));
    } catch (e) {
      print("Failed to read data from the serial device: $e");
    }
    return const Stream.empty();
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
  late final BluetoothDevice _device;
  BluetoothCharacteristic? _characteristics;
  String channel;

  late Stream<List<int>> _stream;

  BlueToothDevice(this._device, this.channel);

  @override
  Future<void> connect() async {
    try {
      print("Connecting to the bluetooth device...");
      await _device.connect();
      List<BluetoothService> services = await _device.discoverServices();
      for (var service in services) {
        for (var element in service.characteristics) {
          if (element.uuid.toString().contains(channel)) {
            _characteristics = element;
            _stream = _characteristics!.value;
            print(_characteristics);
            continue;
          }
        }
      }
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
    return _device.name;
  }
}

class VirtualDevice extends Device {
  late StreamController<String> _dataStreamController;
  late Timer _sinusoidTimer;
  double x = 0.0;
  double index = 0;

  VirtualDevice();

  @override
  Future<void> connect() async {
    // Initialize the data stream controller
    _dataStreamController = StreamController<String>();

    // Start generating and sending sinusoidal waveform after a connection is established
    _sinusoidTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      // _dataStreamController.add(
      //     '!$index?yaw:${cos(x) * 20};pitch:${sin(x) * 20};roll:${cos(x + 1) * 20};accyaw:${cos(x) * 20};accr:${sin(x) * 20};accp:${cos(x + 1) * 20};vyaw:${cos(x) * 20};vp:${sin(x) * 20};vr:${cos(x + 1) * 20};accx:${cos(x) * 20};accy:${sin(x) * 20};accz:${cos(x + 1) * 20};vx:${cos(x) * 20};vy:${sin(x) * 20};vz:${cos(x + 1) * 20};alt:${cos(x) * 20};long:${sin(x) * 20};lat:${cos(x + 1) * 20};\n');
      _dataStreamController.add(
          '!$index?yaw:${cos(x) * 20};pitch:${sin(x) * 20};roll:${cos(x + 1) * 20};acc:(accroll:${cos(x + 1) * 20},accpitch:${cos(x) * 20},accroll:${sin(x) * 20},);\n');
      x += 0.05;
      index++;
    });
  }

  @override
  Future<void> disconnect() async {
    // Stop the sinusoid generation timer
    _sinusoidTimer.cancel();

    // Close the data stream controller
    await _dataStreamController.close();

    print('VirtualDevice disconnected.');
  }

  @override
  Stream<String> readData() {
    return _dataStreamController.stream;
  }

  @override
  void writeData(Uint8List data) {
    if (!_dataStreamController.isClosed) {
      _dataStreamController.add(String.fromCharCodes(data));
    }
  }

  @override
  String getType() {
    return 'Virtual Device';
  }

  @override
  String getName() {
    return 'Virtual Device';
  }
}
