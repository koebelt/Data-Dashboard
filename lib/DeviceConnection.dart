import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

class DeviceConnection extends StatefulWidget {
  const DeviceConnection({super.key});

  @override
  State<DeviceConnection> createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection> {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> _devicesList = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  BluetoothDevice? _connectingDevice;
  Set<BluetoothDevice> _connectedDevices = Set<BluetoothDevice>();



  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

  void _startScanning() {
    _devicesList.clear();
    _scanSubscription = _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_devicesList.contains(result.device) && result.device.name.isNotEmpty) {
          setState(() {
            _devicesList.add(result.device);
          });
        }
      }
    });

    _flutterBlue.startScan(timeout: Duration(seconds: 4));
  }

void _stopScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _devicesList.clear();
    _flutterBlue.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _connectingDevice = device;
    });

    try {
      // Connect to the selected Bluetooth device
      await device.connect();
      // Add the connected device to the connected devices set
      _connectedDevices.add(device);
    } catch (e) {
      print('Failed to connect to the device: $e');
      // Handle connection failure if necessary
    } finally {
      setState(() {
        _connectingDevice = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = _devicesList[index];
          bool isConnected = _connectedDevices.contains(device);
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            trailing: isConnected ? Text('Connected') : _buildConnectButton(device),
          );
        },
      ),
    );
  }

  Widget _buildConnectButton(BluetoothDevice device) {
    if (_connectingDevice != null && _connectingDevice == device) {
      return SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          _connectToDevice(device); // Connect to the selected device
        },
        child: Text('Connect'),
      );
    }
  }
}