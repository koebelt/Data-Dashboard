import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'BluetoothDeviceConnection.dart';
import 'SerialDeviceConnection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

class DeviceConnection extends StatefulWidget {
  const DeviceConnection({super.key});

  @override
  State<DeviceConnection> createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection> {
  FlutterBluePlus? _flutterBlue;
  bool _isBluetoothSupported = false;
  bool _isSerialSupported = false;
  StreamSubscription<BluetoothState>? _stateSubscription;
  BluetoothState _bluetoothState = BluetoothState.unknown;

  @override
  void initState() {
    super.initState();
    _checkBluetoothSupport();
    _chechSerialSupport();
  }

  Future<void> _checkBluetoothSupport() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _isBluetoothSupported = false;
      });
    } else {
      _flutterBlue = FlutterBluePlus.instance;
      bool isAvailable = await _flutterBlue!.isAvailable;
      setState(() {
        _isBluetoothSupported = isAvailable;
      });

      if (isAvailable) {
        _stateSubscription = _flutterBlue!.state.listen((state) {
          setState(() {
            _bluetoothState = state;
          });
        });
      }
    }
  }

  void _chechSerialSupport() async {
    if (Platform.isAndroid || Platform.isIOS) {
      setState(() {
        _isSerialSupported = false;
      });
    } else {
      setState(() {
        _isSerialSupported = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DeviceConnection'),
      ),
      body: Column(
        children: [
          Text('Bluetooth'),
          if (!_isBluetoothSupported)
            Text('Bluetooth is not available on this device')
          else if (_bluetoothState == BluetoothState.on)
            Container(
              height: 400,
              child: BluetoothDeviceConnection(),
            )
          else if (_bluetoothState == BluetoothState.off)
            Container(
                child: Row(
              children: [
                Text('Bluetooth is off'),
                ElevatedButton(
                  onPressed: () {
                    _flutterBlue!.turnOn();
                  },
                  child: Text('Turn on'),
                ),
              ],
            ))
          else
            Text('Bluetooth state unknown, permission might be missing'),
          Text('Serial'),
          if (!_isSerialSupported)
            Text('Serial is not available on this device')
          else
          Container(
            height: 400,
            child: SerialDeviceConnection(),
          )
        ],
      ),
    );
  }
}
