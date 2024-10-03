import 'package:data_dashboard/Dashboard/DashboardPage.dart';
import 'package:data_dashboard/Device/Device.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/DeviceCardWidget.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/DevicePage.dart';
import 'package:data_dashboard/LandingPage.dart';
import 'package:data_dashboard/PageWidget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Device? device;

  Future setDevice(Device? device) async {
    if (this.device != null) {
      await this.device!.disconnect();
    }

    if (device != null) {
      await device.connect();
    }

    setState(() {
      this.device = device;
    });
  }

  _pushToDashboard() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DashboardPage()));
  }

  _pushToDevice() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DevicePage(
              setDevice: setDevice,
              device: device,
            )));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 900 ? 100 : 20,
                vertical: 20),
            child: DeviceCardWidget(device: device, setDevice: setDevice),
          ),
          if (device != null) DashboardPage() else LandingPage(),
        ],
      ),
    );
  }
}
