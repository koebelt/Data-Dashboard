import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';
import '../Device.dart';
import 'package:data_dashboard/Device/BluetoothDevice.dart' as device;

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
  bool _isAdapterReady = false;

  @override
  Widget build(BuildContext context) {
    return !_isAdapterReady
        ? AdapterStateInterface(setAdapterState: (bool state) {
            setState(() {
              _isAdapterReady = state;
            });
          })
        : BluetoothDeviceList(
            setDevice: widget.setDevice,
            device: widget.device,
            setAdapterState: (bool state) {
              setState(() {
                _isAdapterReady = state;
              });
            });
  }
}

class BluetoothDeviceList extends StatefulWidget {
  const BluetoothDeviceList(
      {super.key,
      required this.setDevice,
      required this.device,
      required this.setAdapterState});

  final Function(Device?) setDevice;
  final Device? device;
  final Function(bool) setAdapterState;

  @override
  State<BluetoothDeviceList> createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends State<BluetoothDeviceList> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      widget.setAdapterState(state == BluetoothAdapterState.on);
      if (mounted) {
        setState(() {});
      }
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      results.removeWhere((element) => element.device.platformName.isEmpty);
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    }, onError: (e) {
      print(e);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() {
          _isScanning = state;
        });
      }
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: () async {
          await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var result in _scanResults) ...{
                if (_scanResults.indexOf(result) != 0 &&
                    result.device.platformName.isNotEmpty)
                  const Divider(
                    thickness: 0.5,
                  ),
                if (result.device.platformName.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      if (widget.device != null &&
                          widget.device!.getName() ==
                              result.device.platformName) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  "Disconnect from Bluetooth Device"),
                              content: const Text(
                                  "Are you sure you want to disconnect?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await widget.setDevice(null);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Disconnect"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Connect to Bluetooth Device"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Are you sure you want to connect to ${result.device.platformName}?"),
                                  // Text(
                                  //     "Select the Service and Characteristics om which you are transmitting data"),
                                  // DropdownButton(
                                  //     items: services.map(
                                  //       (service) {
                                  //         return DropdownMenuItem(
                                  //           child: Text(service.uuid.str),
                                  //           value: service.uuid,
                                  //         );
                                  //       },
                                  //     ).toList(),
                                  //     onChanged: (value) {
                                  //       selectedService = services.firstWhere(
                                  //           (element) => element.uuid == value);
                                  //       characteristics =
                                  //           selectedService.characteristics;
                                  //       setState(() {});
                                  //     },
                                  //     value: selectedService.uuid),
                                  // DropdownButton(
                                  //     items: characteristics.map(
                                  //       (characteristic) {
                                  //         return DropdownMenuItem(
                                  //           child:
                                  //               Text(characteristic.uuid.str),
                                  //           value: characteristic.uuid,
                                  //         );
                                  //       },
                                  //     ).toList(),
                                  //     onChanged: (value) {
                                  //       characteristics = characteristics
                                  //           .where((element) =>
                                  //               element.uuid == value)
                                  //           .toList();
                                  //       setState(() {});
                                  //     },
                                  //     value: characteristics.first.uuid),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await widget.setDevice(
                                        device.BluetoothDevice(result.device));
                                    // Navigator.of(context).pop();
                                  },
                                  child: const Text("Connect"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(result.device.platformName),
                        if (widget.device != null &&
                            widget.device is device.BluetoothDevice &&
                            (widget.device as device.BluetoothDevice)
                                    .getName() ==
                                result.device.advName)
                          const Icon(Icons.check)
                      ],
                    ),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class AdapterStateInterface extends StatefulWidget {
  const AdapterStateInterface({super.key, required this.setAdapterState});

  final Function(bool) setAdapterState;

  @override
  State<AdapterStateInterface> createState() => _AdapterStateInterfaceState();
}

class _AdapterStateInterfaceState extends State<AdapterStateInterface> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      widget.setAdapterState(state == BluetoothAdapterState.on);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_adapterState == BluetoothAdapterState.off ||
              _adapterState == BluetoothAdapterState.turningOff)
            const Text("Please turn on the bluetooth adapter"),
          if (_adapterState == BluetoothAdapterState.on ||
              _adapterState == BluetoothAdapterState.turningOn)
            const Text("Bluetooth adapter is on"),
          if (_adapterState == BluetoothAdapterState.unavailable)
            const Text("Bluetooth adapter is unavailable"),
          if (_adapterState == BluetoothAdapterState.unauthorized)
            const Text("Bluetooth adapter is unauthorized, go to settings"),
          if (_adapterState == BluetoothAdapterState.unknown) ...{
            Text("We are checking if we have access to the bluetooth adapter"),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              strokeCap: StrokeCap.round,
            )
          },
        ],
      ),
    );
  }
}
