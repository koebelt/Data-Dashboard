import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Device.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dashboard/dashboard.dart';
import 'package:ditredi/ditredi.dart';
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
  Map<String, List<Data>> dataMap = {};
  Map<String, List<FlSpot>> visibleDataMap = {};
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

  int? slot;

  setSlot() {
    var w = MediaQuery.of(context).size.width;
    setState(() {
      slot = w > 600
          ? w > 900
              ? w > 1200
                  ? w > 1500
                      ? 12
                      : 10
                  : 8
              : 6
          : 4;
    });
  }

  late DashboardItemController itemController = DashboardItemController(
    items: [
      DashboardItem(width: 6, height: 6, identifier: "ypr"),
      DashboardItem(width: 4, height: 4, identifier: "plane"),
      DashboardItem(width: 4, height: 4, identifier: "accypr"),
      DashboardItem(width: 4, height: 4, identifier: "vypr"),
      DashboardItem(width: 4, height: 4, identifier: "accxyz"),
      DashboardItem(width: 4, height: 4, identifier: "vxyz"),
      DashboardItem(width: 4, height: 4, identifier: "alt"),
      DashboardItem(width: 4, height: 4, identifier: "long"),
      DashboardItem(width: 4, height: 4, identifier: "lat"),
    ],
  );

  Future<void> init() async {
    plane =
        Mesh3D(await ObjParser().loadFromResources('assets/paper-plane.obj'));
    await Future.delayed(const Duration(seconds: 1));
    itemController.isEditing = true;
  }

  @override
  void initState() {
    super.initState();
    controller = DiTreDiController();
    init();
  }

  List<dynamic>? parseReceivedData(String receivedString) {
    int startIndex = receivedString.indexOf('!');
    int endIndex = receivedString.indexOf('\n', startIndex + 1);

    if (startIndex != -1 && endIndex != -1) {
      String line = receivedString.substring(startIndex + 1, endIndex - 1);

      List<String> parts = line.split('?');
      if (parts.length == 2) {
        double? index = double.tryParse(parts[0]);
        if (index != null) {
          RegExp valueRegex = RegExp(r'([a-zA-Z]+):(-?[0-9]+).([0-9]+)');
          Iterable<Match> valueMatches = valueRegex.allMatches(parts[1]);
          // print(valueMatches);
          for (Match match in valueMatches) {
            String key = match.group(1)!;
            double? value =
                double.tryParse(match.group(2)! + '.' + match.group(3)!);
            if (value != null) {
              dataMap[key] = dataMap[key] ?? [];
              if (dataMap[key]!.lastOrNull == null) {
                visibleDataMap[key] = visibleDataMap[key] ?? [];
                dataMap[key]!.add(Data(value, index));
                visibleDataMap[key]!.add(FlSpot(index, value));
              } else if (dataMap[key]!.lastOrNull?.index != null &&
                  dataMap[key]!.lastOrNull!.index < index) {
                visibleDataMap[key] = visibleDataMap[key] ?? [];
                dataMap[key]!.add(Data(value, index));
                visibleDataMap[key]!.add(FlSpot(index, value));
                if (visibleDataMap[key]!.length > 100) {
                  visibleDataMap[key]!.removeAt(0);
                }
              }
            }
            // print(key);
            // print(value);
          }
        }
      }
      // if (parts.length == 2) {
      //   double? index = double.tryParse(parts[0]);
      //   double? data = double.tryParse(parts[1]);
      //   if (index != null && data != null) {
      //     return [index, data];
      //   }
      // }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    slot = w > 600
        ? w > 900
            ? w > 1200
                ? w > 1500
                    ? 12
                    : 10
                : 8
            : 6
        : 4;

    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         itemController.isEditing = !itemController.isEditing;
      //       },
      //       icon: Icon(
      //         itemController.isEditing
      //             ? Icons.check_box
      //             : Icons.check_box_outline_blank,
      //       ),
      //     ),
      //   ],
      // ),
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
              itemController.isEditing = true;
              parseReceivedData(snapshot.data!);
              controller?.update(
                rotationX: dataMap["pitch"]!.lastOrNull!.value,
                rotationY: dataMap["yaw"]!.lastOrNull!.value,
                rotationZ: dataMap["roll"]!.lastOrNull!.value * -1,
              );
            }

            return Dashboard(
              padding: EdgeInsets.all(50),
              dashboardItemController: itemController,
              slotCount: slot!,
              itemStyle: ItemStyle(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  shadowColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 200),
                  borderOnForeground: false,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 10,
                  textStyle: const TextStyle(color: Colors.black),
                  type: MaterialType.card),
              slideToTop: false,
              shrinkToPlace: false,
              editModeSettings: EditModeSettings(
                  curve: Curves.easeInOutCirc,
                  duration: const Duration(milliseconds: 200),
                  fillEditingBackground: true,
                  resizeCursorSide: 20,
                  shrinkOnMove: true,
                  longPressEnabled: true,
                  panEnabled: true,
                  backgroundStyle: const EditModeBackgroundStyle(
                      fillColor: Color.fromARGB(10, 10, 10, 10),
                      lineWidth: 0,
                      lineColor: Colors.transparent,

                      // line by vertical space
                      dualLineHorizontal: false,

                      // line by horizontal space
                      dualLineVertical: false)),
              itemBuilder: (item) {
                switch (item.identifier) {
                  case "ypr":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              color: Colors.blue,
                              spots: visibleDataMap["yaw"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.green,
                              spots: visibleDataMap["pitch"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.red,
                              spots: visibleDataMap["roll"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Roll',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case "accypr":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              color: Colors.blue,
                              spots: visibleDataMap["accyaw"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.green,
                              spots: visibleDataMap["accp"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.red,
                              spots: visibleDataMap["accr"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Acc Yaw',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                  case "vypr":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              color: Colors.blue,
                              spots: visibleDataMap["vyaw"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.green,
                              spots: visibleDataMap["vp"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.red,
                              spots: visibleDataMap["vr"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'V Yaw',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case "accxyz":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              color: Colors.blue,
                              spots: visibleDataMap["accx"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.green,
                              spots: visibleDataMap["accy"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.red,
                              spots: visibleDataMap["accz"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Acc X',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                  case "vxyz":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              color: Colors.blue,
                              spots: visibleDataMap["vx"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.green,
                              spots: visibleDataMap["vy"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              color: Colors.red,
                              spots: visibleDataMap["vz"] ?? [],
                              isCurved: false,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'V X',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case "alt":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: visibleDataMap["alt"] ?? [],
                              isCurved: true,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Altitude',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case "long":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: visibleDataMap["long"] ?? [],
                              isCurved: true,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Longitude',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case "lat":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: visibleDataMap["lat"] ?? [],
                              isCurved: true,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Latitude',
                                style: TextStyle(fontSize: 16),
                              ),
                              axisNameSize: 20,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                  case "plane":
                    return (DiTreDi(
                      figures: [
                        if (plane != null) plane!,
                      ],
                      controller: controller,
                    ));

                  default:
                    return Text(item.identifier);
                }
                //return widget
              },
            );
          },
        ),
      ),
    );
  }
}

class Data {
  Data(this.value, this.index);
  final double value;
  final double index;
}

// yo mec faut pas laisser ton pc unlock comme ça c'est super dangereux frérot
