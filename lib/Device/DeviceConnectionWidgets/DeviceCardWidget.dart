import 'package:data_dashboard/Device/BluetoothDevice.dart';
import 'package:data_dashboard/Device/Device.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/DevicePage.dart';
import 'package:data_dashboard/Device/SerialDevice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeviceCardWidget extends StatefulWidget {
  const DeviceCardWidget(
      {super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

  @override
  State<DeviceCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<DeviceCardWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DevicePage(
                  setDevice: widget.setDevice,
                  device: widget.device,
                )));
      },
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: (() {
                  if (widget.device == null) {
                    return SvgPicture.asset(
                      "assets/usb.svg",
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                      width: 50,
                      height: 50,
                    );
                  } else if (widget.device is BluetoothDevice) {
                    return const Icon(
                      Icons.bluetooth,
                      size: 50,
                    );
                  } else if (widget.device is SerialDevice) {
                    return const Icon(
                      Icons.usb,
                      size: 50,
                    );
                  } else {
                    return const Icon(
                      Icons.wifi,
                      size: 50,
                    );
                  }
                }())),
            if (widget.device != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device!.getName(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        widget.device!.getType() + " Device",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "No Device Connected",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
