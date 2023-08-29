import 'dart:io';

import 'package:flutter/material.dart';

import 'Data.dart';

class SettingPage extends StatefulWidget {
  const SettingPage(
      {super.key, required this.setting, required this.setSetting});

  final Setting setting;
  final Function(Setting) setSetting;

  @override
  State<SettingPage> createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeviceConnection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Has JoyStick'),
                Switch(
                  value: widget.setting.hasJoysticks,
                  onChanged: (value) {
                    widget
                        .setSetting(Setting(value, widget.setting.hasCommand));
                    setState(() {
                      widget.setting.hasJoysticks = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Has Command'),
                Switch(
                  value: widget.setting.hasCommand,
                  onChanged: (value) {
                    widget.setSetting(
                        Setting(widget.setting.hasJoysticks, value));
                    setState(() {
                      widget.setting.hasCommand = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
