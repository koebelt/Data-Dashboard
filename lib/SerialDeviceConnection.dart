import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialDeviceConnection extends StatefulWidget {
  const SerialDeviceConnection({super.key});

  @override
  State<SerialDeviceConnection> createState() => _SerialDeviceConnectionState();
}

class _SerialDeviceConnectionState extends State<SerialDeviceConnection> {
  var availablePorts = [];

  @override
  void initState() {
    super.initState();
    initPorts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initPorts() {
    print("initPorts");
    setState(() => availablePorts = SerialPort.availablePorts);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        children: [
          for (final address in availablePorts)
            Builder(builder: (context) {
              print(address);
              final port = SerialPort(address);
              return ExpansionTile(
                title: Text(address),
                children: [
                  CardListTile('Description', port.description),
                  CardListTile('Transport', port.transport.toTransport()),
                  CardListTile('USB Bus', port.busNumber?.toPadded()),
                  CardListTile('USB Device', port.deviceNumber?.toPadded()),
                  CardListTile('Vendor ID', port.vendorId?.toHex()),
                  CardListTile('Product ID', port.productId?.toHex()),
                  CardListTile('Manufacturer', port.manufacturer),
                  CardListTile('Product Name', port.productName),
                  CardListTile('Serial Number', port.serialNumber),
                  CardListTile('MAC Address', port.macAddress),
                ],
              );
            }),
        ],
      ),
    );
  }
}

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  CardListTile(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}
