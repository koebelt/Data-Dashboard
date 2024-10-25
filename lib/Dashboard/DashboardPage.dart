import 'dart:async';

import 'package:data_dashboard/Data.dart';
import 'package:data_dashboard/PageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:data_dashboard/Dashboard/LayoutProvider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.dataStream});

  final Stream<List<int>>? dataStream;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DataList dataList = DataList(dataList: []);
  StreamSubscription? dataSubscription;

  @override
  void initState() {
    super.initState();
    dataSubscription = widget.dataStream?.listen((event) {
      setState(() {
        dataList.addDataFromBytes(event);
      });
    });
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dataStream != widget.dataStream) {
      dataSubscription?.cancel();
      dataSubscription = widget.dataStream?.listen((event) {
        setState(() {
          dataList.addDataFromBytes(event);
        });
      });
    }
  }

  @override
  void dispose() {
    dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 900 ? 100 : 20,
          vertical: 20),
      child: Column(
        children: [
          LayoutProvider.fromData(
            context: context,
            dataList: dataList,
          ),
        ],
      ),
    );
  }
}
