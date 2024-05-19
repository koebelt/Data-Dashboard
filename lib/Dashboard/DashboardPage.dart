import 'package:data_dashboard/Data.dart';
import 'package:data_dashboard/PageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:data_dashboard/Dashboard/LayoutProvider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return PageWidget(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Dashboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            LayoutProvider.fromData(
              context: context,
              dataList: DataList.fromMap({
                "data1": "data",
                "pos": {"x": 0.0, "y": 0.0, "z": 0.0},
                "loc": {"longitude": 0.0, "latitude": 0.0},
                "data2": "data",
                "data3": "data",
              }),
              layoutTypes: [
                LayoutType.PositionData3DViewer,
                LayoutType.LocationDataMap,
                LayoutType.GraphData,
                LayoutType.RawData
              ],
            ),
          ],
        ),
      ),
    );
  }
}
