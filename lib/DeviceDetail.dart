import 'dart:typed_data';

import 'package:flutter/material.dart';


class DeviceDetails extends StatefulWidget {
  final String deviceId;

  DeviceDetails(this.deviceId);

  @override
  State<StatefulWidget> createState() {
    return _DeviceDetailsState();
  }
}

class _DeviceDetailsState extends State<DeviceDetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeripheralDetailPage'),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}