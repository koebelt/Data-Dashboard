import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Device.dart';
import 'Dashboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ditredi/ditredi.dart';
import "Data.dart";
// import 'package:vector_math/vector_math_64.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Data Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Device? device;
  Stream<String>? dataStream;
  // List<Data> data = [];
  Map<String, List<List<Data>>> dataMap = {};
  Map<String, List<FlSpot>> visibleDataMap = {};
  Map<String, DashboardItem> graphs = {};
  DiTreDiController? controller;
  Mesh3D? plane;
  // List<Data> visibleData = [];
  // List<FlSpot> spots = [];

  setDevice(Device? device) {
    setState(() {
      dataMap.clear();
      visibleDataMap.clear();
      this.device = device;
      if (this.device == null) {
        Navigator.pop(context);
        return;
      }
      this.device!.connect().then((_) {
        this.dataStream = device?.readData();
        Navigator.pop(context);
      });
    });
  }

  Future<void> init() async {
    plane =
        Mesh3D(await ObjParser().loadFromResources('assets/paper-plane.obj'));
  }

  @override
  void initState() {
    super.initState();
    controller = DiTreDiController();
    init();
  }

  void parseReceivedData(String receivedString) {
    int startIndex = receivedString.indexOf('!');
    int endIndex = receivedString.indexOf('\n', startIndex + 1);

    if (startIndex != -1 && endIndex != -1) {
      String line = receivedString.substring(startIndex + 1, endIndex - 1);

      List<String> parts = line.split('?');
      if (parts.length == 2) {
        double? index = double.tryParse(parts[0]);
        if (index != null) {
          // print(parts[1]);
          final regex = RegExp(r'(\w+):(-?[0-9.]+);');
          final groupRegex = RegExp(r'(\w+):\((\S+)+\)');
          final insideRegex = RegExp(r'(\w+):(-?[0-9.]+),');

          Iterable<Match> matches = regex.allMatches(parts[1]);
          Iterable<Match> groupMatches = groupRegex.allMatches(parts[1]);

          for (Match match in groupMatches) {
            String key = match.group(1)!;
            String group = match.group(2)!;
            Iterable<Match> insideMatches = insideRegex.allMatches(group);
            List<Data> insideValues = [];
            dataMap[key] = dataMap[key] ?? [];
            for (Match insideMatch in insideMatches) {
              String insideKey = insideMatch.group(1)!;
              double? insideValue = double.tryParse(insideMatch.group(2)!);
              if (insideValue != null) {
                insideValues.add(Data(insideKey, insideValue, index));
              }
            }
            int i = 0;
            for (Data data in insideValues) {
              dataMap[key]!.length <= i
                  ? dataMap[key]!.add([data])
                  : dataMap[key]![i].add(data);
              i++;
            }
          }
          for (Match match in matches) {
            String key = match.group(1)!;
            double? value = double.tryParse(match.group(2)!);
            if (value != null) {
              dataMap[key] = dataMap[key] ?? [];
              dataMap[key]!.length <= 0
                  ? dataMap[key]!.add([Data(key, value, index)])
                  : dataMap[key]![0].add(Data(key, value, index));
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: DeviceIcon(device: device, setDevice: setDevice),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: Padding(
        padding: EdgeInsets.all(0),
        child: StreamBuilder<String>(
            stream: dataStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Awaiting result...');
              }
              // print(snapshot!.data);
              if (snapshot.data != null) {
                parseReceivedData(snapshot.data!);
              }

              return Dashboard(
                items: dataMap.keys
                    .map(
                      (e) => DashboardItem(
                        title: e,
                        dataPoints: List.generate(
                            dataMap[e]!.length,
                            (index) => dataMap[e]![index].length > 400
                                ? dataMap[e]![index]
                                    .sublist(dataMap[e]![index].length - 400)
                                : dataMap[e]![index]),
                      ),
                    )
                    .toList(),
              );
            }),
      ),
    );
  }
}
