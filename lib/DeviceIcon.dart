import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';

class DeviceIcon extends StatefulWidget {
  const DeviceIcon({super.key});

  @override
  State<DeviceIcon> createState() => _DeviceIconState();
}

class _DeviceIconState extends State<DeviceIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, right: 15),
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Container(),
        onPressed: () => {
          
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
    );
  }
}
