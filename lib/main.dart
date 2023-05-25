import 'dart:ffi';

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
  int initialTime = DateTime.now().millisecondsSinceEpoch;

  setDevice(Device? device) {
    setState(() {
      this.device = device;
      this.device!.connect().then((_) {
        this.dataStream = device?.readData();
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
      DashboardItem(width: 2, height: 3, identifier: "id_1"),
      DashboardItem(
          startX: 3, startY: 4, width: 3, height: 1, identifier: "id_2"),
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

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    slot = w > 600
        ? w > 900
            ? 8
            : 6
        : 4;
    return Scaffold(
      floatingActionButton: DeviceIcon(device: device, setDevice: setDevice),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: Padding(
        padding: EdgeInsets.only(top: 100),
        child: StreamBuilder<String>(
          stream: dataStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Awaiting result...');
            }
            if (snapshot.data != null) {
              this.data.add(Data(double.parse(snapshot.data!), initialTime));
              this
                  .visibleData
                  .add(Data(double.parse(snapshot.data!), initialTime));
              this.spots.add(FlSpot(
                  (DateTime.now().millisecondsSinceEpoch - initialTime)
                      .toDouble(),
                  double.parse(snapshot.data!)));
            }
            if (this.visibleData.length > 400) {
              this.visibleData.removeAt(0);
            }
            if (this.spots.length > 400) {
              this.spots.removeAt(0);
            }

            return Dashboard(
              dashboardItemController: itemController,
              itemBuilder: (item) {
                return Text(item.identifier);
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
              slideToTop: true,
              editModeSettings: EditModeSettings(

                  // animation settings
                  curve: Curves.easeInOutCirc,
                  duration: const Duration(milliseconds: 200),

                  // fill editing item actual size
                  fillEditingBackground: true,

                  // space that can be held to resize
                  resizeCursorSide: 20,

                  // draw lines for slots
                  // paintBackgroundLines: true,

                  // shrink items when editing if possible and necessary
                  shrinkOnMove: true,

                  // long press to edit
                  longPressEnabled: true,

                  // pan to edit
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
  Data(this.value, int inital) {
    this.time = DateTime.now().millisecondsSinceEpoch - inital;
  }
  final double value;
  late num time;
}
