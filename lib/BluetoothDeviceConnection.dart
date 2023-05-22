import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

class BluetoothDeviceConnection extends StatefulWidget {
  const BluetoothDeviceConnection({super.key});

  @override
  State<BluetoothDeviceConnection> createState() =>
      _BluetoothDeviceConnectionState();
}

class _BluetoothDeviceConnectionState extends State<BluetoothDeviceConnection> {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> _devicesList = [];
  StreamSubscription<ScanResult>? _scanSubscription;
  BluetoothDevice? _connectingDevice;
  Set<BluetoothDevice> _connectedDevices = Set<BluetoothDevice>();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _flutterBlue.stopScan();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    print('Scanning Started');
    _devicesList.clear();
    _scanSubscription = _flutterBlue.scan().listen((scanResult) {
      if (mounted) {
      setState(() {
        if (!_devicesList.contains(scanResult.device)) {
          _devicesList.add(scanResult.device);
        }
      });
    }
  }, onDone: _stopScanning);
    Timer(Duration(seconds: 4), _stopScanning);
  }

  void _stopScanning() {
    print('Scanning Stopped');
    if (mounted) {
    setState(() {
      _isScanning = false;
    });
  }
    _scanSubscription?.cancel();
    _scanSubscription = null;
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

  Future<void> _refreshDevices() async {
    _startScanning();
    await Future.delayed(
        Duration(seconds: 2)); // Simulating a delay for refreshing
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDevices,
      child: Column(
        children: [
          if (_isScanning)
            _buildLoadingIndicator(), // Show loading indicator if scanning is ongoing
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = _devicesList[index];
                bool isConnected = _connectedDevices.contains(device);
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  trailing: isConnected
                      ? Text('Connected')
                      : _buildConnectButton(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
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
