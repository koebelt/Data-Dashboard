import 'package:flutter/material.dart';
import 'DeviceConnection.dart';
import 'Device.dart';

class DeviceIcon extends StatefulWidget {
  const DeviceIcon({super.key, required this.device, required this.setDevice});

  final Device? device;
  final Function(Device?) setDevice;

  @override
  State<DeviceIcon> createState() => _DeviceIconState();
}

class _DeviceIconState extends State<DeviceIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 15),
      child: ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.white),
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
          fixedSize: MaterialStatePropertyAll(Size(60, 60)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
        ),
        child: widget.device != null
            ? Image.asset(
                'assets/connectedIcon.png',
                height: 30,
                width: 30,
              )
            : Image.asset(
                'assets/disconnectedIcon.png',
                height: 30,
                width: 30,
              ),
        onPressed: () {
          Navigator.of(context).push(_createRoute());
        },
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          DeviceConnection(device: widget.device, setDevice: widget.setDevice),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
