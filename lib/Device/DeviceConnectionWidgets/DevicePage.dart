import 'dart:io';
import 'package:data_dashboard/Device/Device.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/BluetoothDeviceConnection.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/SerialDeviceConnection.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/VirtualDeviceConnection.dart';
import 'package:data_dashboard/PageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  bool _isBluetoothSupported = false;

  Future _checkBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      setState(() {
        _isBluetoothSupported = false;
      });
    } else {
      setState(() {
        _isBluetoothSupported = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 900 ? 100 : 20,
            vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Connect a Device",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            DeviceSection(
              icon: const Icon(Icons.bluetooth),
              title: "Bluetooth",
              isSupported: _isBluetoothSupported,
              child: BluetoothDeviceConnection(
                device: widget.device,
                setDevice: widget.setDevice,
              ),
            ),
            const DeviceSection(
              icon: Icon(Icons.wifi),
              title: "Wi-Fi",
              isSupported: false,
            ),
            DeviceSection(
              icon: const Icon(Icons.usb),
              title: "USB Serial",
              isSupported:
                  Platform.isMacOS || Platform.isWindows || Platform.isLinux,
              child: SerialDeviceConnection(
                device: widget.device,
                setDevice: widget.setDevice,
              ),
            ),
            DeviceSection(
              title: "Virtual Device",
              icon: const Icon(Icons.developer_mode),
              isSupported: true,
              child: VirtualDeviceConnection(
                  device: widget.device, setDevice: widget.setDevice),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceSection extends StatelessWidget {
  const DeviceSection(
      {super.key,
      required this.icon,
      required this.title,
      this.child,
      required this.isSupported});

  final Widget icon;
  final String title;
  final Widget? child;
  final bool isSupported;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: ExpansionTile(
        enabled: isSupported,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        title: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: isSupported
            ? null
            : const Text(
                "Not currently supported on your device",
              ),
        children: [
          if (isSupported)
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 500),
              width: double.infinity,
              child: child ?? const Text("No device available"),
            ),
        ],
      ),
    );
  }
}
