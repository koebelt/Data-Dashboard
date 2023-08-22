import 'dart:io';

import 'package:flutter/material.dart';
import 'BluetoothDeviceConnection.dart';
import 'SerialDeviceConnection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';
import 'Device.dart';

class DeviceConnection extends StatefulWidget {
  const DeviceConnection(
      {super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

  @override
  State<DeviceConnection> createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection> {
  FlutterBluePlus? _flutterBlue;
  bool _isBluetoothSupported = false;
  bool _isSerialSupported = false;
  final BluetoothState _bluetoothState = BluetoothState.unknown;

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
        title: const Text('DeviceConnection'),
      ),
      body: widget.device != null
          ? Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  const Text("You are connected to a ",
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  Text(widget.device!.getType(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                  const Text(" device named ",
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  Text(widget.device!.getName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                  ElevatedButton(
                      onPressed: () {
                        widget.device!.disconnect();
                        widget.setDevice(null);
                      },
                      child: const Text('Disconnect'))
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Bluetooth',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (!_isBluetoothSupported)
                        const Text('Bluetooth is not available on this device')
                      else if (_bluetoothState == BluetoothState.on)
                        Expanded(
                          child: BluetoothDeviceConnection(
                              device: widget.device,
                              setDevice: widget.setDevice),
                        )
                      else if (_bluetoothState == BluetoothState.off)
                        Row(
                          children: [
                            const Text('Bluetooth is off'),
                            ElevatedButton(
                              onPressed: () {
                                _flutterBlue!.turnOn();
                              },
                              child: const Text('Turn on'),
                            ),
                          ],
                        )
                      else
                        const Text(
                            'Bluetooth state unknown, permission might be missing'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Serial',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (!_isSerialSupported)
                        const Text('Serial is not available on this device')
                      else
                        Expanded(
                          child: SerialDeviceConnection(
                              device: widget.device,
                              setDevice: widget.setDevice),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Virtual Device',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        child: const Text('Connect'),
                        onPressed: () async {
                          widget.setDevice(VirtualDevice());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
