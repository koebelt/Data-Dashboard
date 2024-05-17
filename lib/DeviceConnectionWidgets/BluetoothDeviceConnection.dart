import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as bluetooth;

import 'dart:async';
import '../Device/Device.dart';
import 'package:data_dashboard/Device/BluetoothDevice.dart';

class BluetoothDeviceConnection extends StatefulWidget {
  BluetoothDeviceConnection(
      {super.key, required this.device, required this.setDevice});

  Device? device;
  final Function(Device?) setDevice;

  @override
  State<BluetoothDeviceConnection> createState() =>
      _BluetoothDeviceConnectionState();
}

class _BluetoothDeviceConnectionState extends State<BluetoothDeviceConnection> {
  bluetooth.FlutterBluePlus _flutterBlue = bluetooth.FlutterBluePlus.instance;
  List<bluetooth.BluetoothDevice> _devicesList = [];
  StreamSubscription<bluetooth.ScanResult>? _scanSubscription;
  bluetooth.BluetoothDevice? _connectingDevice;
  bool _isScanning = false;
  String channel = '';

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
    if (_flutterBlue.isScanningNow == true) {
      return;
    } else {
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
      Timer(Duration(seconds: 8), _stopScanning);
    }
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

  Future<void> _connectToDevice(bluetooth.BluetoothDevice device) async {
    setState(() {
      _connectingDevice = device;
    });

    widget.setDevice(BluetoothDevice(device, channel));
  }

  Future<void> _refreshDevices() async {
    _startScanning();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDevices,
      child: Column(
        children: [
          if (_isScanning)
            _buildLoadingIndicator(), // Show loading indicator if scanning is ongoing
          if (!_isScanning && _devicesList.isEmpty)
            Expanded(
              child: Center(
                child: Text('No devices found'),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                bluetooth.BluetoothDevice device = _devicesList[index];
                return ExpansionTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Channel',
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() {
                          channel = value;
                        });
                      },
                    ),
                    _buildConnectButton(device),
                  ],
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

  Widget _buildConnectButton(bluetooth.BluetoothDevice device) {
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
