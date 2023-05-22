import 'package:flutter/material.dart';
import 'BluetoothDeviceConnection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

class DeviceConnection extends StatefulWidget {
  const DeviceConnection({super.key});

  @override
  State<DeviceConnection> createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DeviceConnection'),
      ),
      body: Column(
        children: [
          Text('Bluetooth'),
          Container(
            height: 400,
            child: BluetoothDeviceConnection(),

          ),
          Text('Serial'),
        ],
      ),
    );
  }
}
