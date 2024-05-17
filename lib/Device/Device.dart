import 'dart:async';
import 'dart:io';
import 'dart:isolate';
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
    _sinusoidTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      _dataStreamController.add(
          '!$index?yaw:${cos(x) * 20};pitch:${sin(x) * 20};roll:${cos(x + 1) * 20};accyaw:${cos(x) * 20};accr:${sin(x) * 20};accp:${cos(x + 1) * 20};vyaw:${cos(x) * 20};vp:${sin(x) * 20};vr:${cos(x + 1) * 20};accx:${cos(x) * 20};accy:${sin(x) * 20};accz:${cos(x + 1) * 20};vx:${cos(x) * 20};vy:${sin(x) * 20};vz:${cos(x + 1) * 20};alt:${cos(x) * 20};long:${sin(x) * 20};lat:${cos(x + 1) * 20};\n');
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
    if (_dataStreamController != null && !_dataStreamController.isClosed) {
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
