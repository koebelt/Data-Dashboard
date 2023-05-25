import 'dart:ffi';

import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Dashboard.dart';
import 'DashboardItem.dart';
import 'Device.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';

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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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

            return Dashboard(childrens: [
              DashboardItem(
                title: "Roll",
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    title: AxisTitle(text: 'Time (s)'),
                    visibleMinimum: 0,
                    visibleMaximum: 400,
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<Data, String>>[
                    LineSeries<Data, String>(
                      dataSource: this.visibleData,
                      xValueMapper: (Data data, _) => data.time.toString(),
                      yValueMapper: (Data data, _) => data.value,
                      // Enable data label
                      // dataLabelSettings:
                      //     DataLabelSettings(isVisible: true)
                    )
                  ],
                ),
              ),
              DashboardItem (
                title: "Pitch",
                child: Container (height: 500,
                  width: 500,
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
                    ),
                  ),
                ),
              ),
            ]);
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
