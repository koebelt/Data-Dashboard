import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../Device.dart';
import 'package:data_dashboard/Device/SerialDevice.dart';

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
  TextEditingController baudRateController = TextEditingController();

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text("Available Ports:"),
        for (var port in availablePorts) ...{
          if (availablePorts.indexOf(port) != 0)
            const Divider(
              thickness: 0.5,
            ),
          TextButton(
            onPressed: () {
              if (widget.device != null && widget.device!.getName() == port) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Disconnect from Serial Port"),
                        content:
                            const Text("Are you sure you want to disconnect?"),
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
                              Navigator.of(context).pop();
                            },
                            child: const Text("Disconnect"),
                          ),
                        ],
                      );
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Connect to Serial Port"),
                        content: TextFormField(
                          controller: baudRateController,
                          decoration: const InputDecoration(
                            labelText: "Baud Rate",
                            hintText: "9600",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a baud rate";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
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
                              if (baudRateController.text.isEmpty ||
                                  int.tryParse(baudRateController.text) ==
                                      null) {
                                return;
                              }
                              var serialDevice = SerialDevice(
                                  port, int.parse(baudRateController.text));
                              await widget.setDevice(serialDevice);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Connect"),
                          ),
                        ],
                      );
                    });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(port),
                // TextButton(onPressed: () async {
                //   var serialPort = SerialPort(port);
                //   await serialPort.open();
                //   var data = Uint8List.fromList([0x01, 0x02, 0x03]);
                //   await serialPort.write(data);
                //   await serialPort.close();
                // }, child: Text("Connect"))
                if (widget.device != null &&
                    widget.device is SerialDevice &&
                    (widget.device as SerialDevice).getName() == port)
                  const Icon(Icons.check)
              ],
            ),
          )
        }
      ],
    );
  }
}
