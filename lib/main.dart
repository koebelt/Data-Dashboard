import 'dart:ffi';

import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Dashboard.dart';
import 'DashboardItem.dart';
import 'Device.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
          child: Dashboard(childrens: [
            DashboardItem(
              title: "Roll",
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
                  }
                  if (this.data.length > 400) {
                    this.data.removeAt(0);
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Time (s)'),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<Data, String>>[
                          LineSeries<Data, String>(
                              dataSource: this.data,
                              xValueMapper: (Data data, _) =>
                                  data.time.toString(),
                              yValueMapper: (Data data, _) => data.value,
                              // Enable data label
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true))
                        ],
                      ),
                      // Text(
                      //   data,
                      //   style: Theme.of(context).textTheme.headline1,
                      // ),
                    ],
                  );
                },
              ),
            ),
          ]),
        ));
  }
}

class Data {
  Data(this.value, int inital) {
    this.time = DateTime.now().millisecondsSinceEpoch - inital;
  }
  final double value;
  late num time;
}
