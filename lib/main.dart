import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Device.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dashboard/dashboard.dart';

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
  List<Data> data = [];
  List<Data> visibleData = [];
  List<FlSpot> spots = [];
  double initialTime = DateTime.now().millisecondsSinceEpoch / 1000;

  setDevice(Device? device) {
    setState(() {
      this.device = device;
      if (this.device == null) {
        Navigator.pop(context);
        return;
      }
      this.device!.connect().then((_) {
        this.dataStream = device?.readData();
        initialTime = DateTime.now().millisecondsSinceEpoch / 1000;
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
              ? 8
              : 6
          : 4;
    });
  }

  late DashboardItemController itemController = DashboardItemController(
    items: [
      DashboardItem(
          startY: 0, startX: 0, width: 3, height: 3, identifier: "id_1"),
      DashboardItem(
          startY: 0, startX: 3, width: 3, height: 3, identifier: "id_2"),
    ],
  );

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));
    itemController.isEditing = true;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  List<dynamic>? parseReceivedData(String receivedString) {
    int startIndex = receivedString.indexOf('!');
    int endIndex = receivedString.indexOf('\n', startIndex + 1);

    if (startIndex != -1 && endIndex != -1) {
      String line = receivedString.substring(startIndex + 1, endIndex - 1);
      List<String> parts = line.split(':');
      if (parts.length == 2) {
        double? index = double.tryParse(parts[0]);
        double? data = double.tryParse(parts[1]);
        if (index != null && data != null) {
          return [index, data];
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    slot = w > 300
        ? w > 600
            ? w > 900
                ? w > 1200
                    ? 10
                    : 8
                : 6
            : 4
        : 3;
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
            print(snapshot!.data);
            if (snapshot.data != null) {
              print(snapshot.data!);
              List<dynamic>? data = parseReceivedData(snapshot.data!);
              if (data != null) {
                double index = data[0];
                double value = data[1];
                if (this.data.isEmpty) {
                  this.data.add(Data(value, index));
                  this.visibleData.add(Data(value, index));
                  this.spots.add(FlSpot(index, value));
                } else if (this.data.lastOrNull!.index < index) {
                  this.data.add(Data(value, index));
                  this.visibleData.add(Data(value, index));
                  this.spots.add(FlSpot(index, value));
                }
              }
            }
            if (this.visibleData.length > 400) {
              this.visibleData.removeAt(0);
            }
            if (this.spots.length > 400) {
              this.spots.removeAt(0);
            }

            return Dashboard(
              padding: EdgeInsets.all(50),
              dashboardItemController: itemController,
              itemBuilder: (item) {
                switch (item.identifier) {
                  case "id_1":
                    return SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(text: 'Time (s)'),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<Data, String>>[
                        LineSeries<Data, String>(
                          dataSource: this.visibleData,
                          xValueMapper: (Data data, _) => data.index.toString(),
                          yValueMapper: (Data data, _) => data.value,
                        )
                      ],
                    );
                  case "id_2":
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 10, bottom: 20, top: 20, right: 20),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
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
                                'Time (s)',
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

                  default:
                    return Text(item.identifier);
                }
                //return widget
              },
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
              editModeSettings: EditModeSettings(
                  curve: Curves.easeInOutCirc,
                  duration: const Duration(milliseconds: 200),
                  fillEditingBackground: true,
                  resizeCursorSide: 20,
                  shrinkOnMove: false,
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
            );
            // return Dashboard(childrens: [
            //   DashboardItem(
            //     title: "Roll",
            //     child: SfCartesianChart(
            //       primaryXAxis: CategoryAxis(
            //         title: AxisTitle(text: 'Time (s)'),
            //         visibleMinimum: 0,
            //         visibleMaximum: 400,
            //       ),
            //       tooltipBehavior: TooltipBehavior(enable: true),
            //       series: <ChartSeries<Data, String>>[
            //         LineSeries<Data, String>(
            //           dataSource: this.visibleData,
            //           xValueMapper: (Data data, _) => data.time.toString(),
            //           yValueMapper: (Data data, _) => data.value,
            //           // Enable data label
            //           // dataLabelSettings:
            //           //     DataLabelSettings(isVisible: true)
            //         )
            //       ],
            //     ),
            //   ),
            //   DashboardItem (
            //     title: "Pitch",
            //     child: Container (height: 500,
            //       width: 500,
            //       child: LineChart(
            //         LineChartData(
            //           lineTouchData: LineTouchData(enabled: false),
            //           lineBarsData: [
            //             LineChartBarData(
            //               spots: spots,
            //               isCurved: true,
            //               isStrokeCapRound: true,
            //               barWidth: 3,
            //               dotData: FlDotData(show: false),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ]);
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
