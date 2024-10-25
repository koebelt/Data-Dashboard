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
  Stream<List<int>> readData();

  // Abstract method to write data to the device
  void writeData(Uint8List data);

  String getType();

  String getName();
}
