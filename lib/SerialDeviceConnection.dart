import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'Device.dart';

class SerialDeviceConnection extends StatefulWidget {
  const SerialDeviceConnection(
      {super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

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
          if (availablePorts.isEmpty)
            Center(child: Text('No serial ports found')),
          for (final address in availablePorts)
            Builder(builder: (context) {
              print(address);
              int baudRate = 9600;
              return ExpansionTile(
                title: Text(address),
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Baudrate',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      baudRate = int.parse(value);
                    },
                  ),
                  ElevatedButton(
                    child: Text('Connect'),
                    onPressed: () async {
                      print(address);
                      widget.setDevice(SerialDevice(address, baudRate));
                    },
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
