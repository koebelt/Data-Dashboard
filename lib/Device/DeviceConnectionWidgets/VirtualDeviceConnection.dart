import 'package:data_dashboard/Device/Device.dart';
import 'package:data_dashboard/Device/VirtualDevice.dart';
import 'package:flutter/material.dart';

class VirtualDeviceConnection extends StatelessWidget {
  const VirtualDeviceConnection(
      {super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (device != null && device is VirtualDevice) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Disconnect from Virtual Device"),
                  content: const Text("Are you sure you want to disconnect?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setDevice(null);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Disconnect"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Connect to Virtual Device"),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("This is a virtual emulated device"),
                      Text("It is used for testing purposes"),
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
                        await setDevice(VirtualDevice());
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
          const Text("Virtual Device"),
          if (device != null && device is VirtualDevice) const Icon(Icons.check)
        ],
      ),
    );
  }
}
