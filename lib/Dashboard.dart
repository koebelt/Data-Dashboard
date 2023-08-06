import 'package:flutter/material.dart';
import 'HorizontalSelector.dart';
import "Data.dart";
import 'package:fl_chart/fl_chart.dart';
import 'package:ditredi/ditredi.dart';

class Dashboard extends StatelessWidget {
  final List<DashboardItem> items;

  Dashboard({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    // You can customize the number of columns based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1; // default number of columns

    if (screenWidth > 1200) {
      crossAxisCount = 3; // use 6 columns for large screens
    } else if (screenWidth > 600) {
      crossAxisCount = 2; // use 4 columns for larger screens
    }
    return crossAxisCount;
  }
}

class DashboardItem extends StatefulWidget {
  const DashboardItem(
      {super.key, required this.title, required this.dataPoints});
  final String title;
  final List<List<Data>> dataPoints;

  @override
  State<DashboardItem> createState() => _DashboardItemState();
}

class _DashboardItemState extends State<DashboardItem> {
  String selected = 'Graph';
  bool stickyScroll = false;
  ScrollController _scrollController = ScrollController();
  DiTreDiController? controller;
  Mesh3D? plane;

  Future<void> init() async {
    plane =
        Mesh3D(await ObjParser().loadFromResources('assets/paper-plane.obj'));
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent !=
          _scrollController.position.pixels) {
        stickyScroll = false;
      } else {
        stickyScroll = true;
      }
      controller = DiTreDiController();
      init();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(widget.title),
          HorizontalSelector(
            items: widget.dataPoints.length == 3
                ? ['Graph', 'Text', '3D']
                : ['Graph', 'Text'],
            onChange: (String value) async {
              setState(() {
                selected = value;
              });
              Future.delayed(Duration(milliseconds: 100), () {
                setState(() {
                  stickyScroll = true;
                });
              });
            },
            height: 30,
          ),
          SizedBox(height: 8),
          Expanded(
            child: selected == 'Graph'
                ? LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(enabled: false),
                      lineBarsData: [
                        for (var i = 0; i < widget.dataPoints.length; i++)
                          LineChartBarData(
                            spots: widget.dataPoints[i]
                                .map((e) => FlSpot(e.index, e.value))
                                .toList(),
                            color: Colors.primaries[i * 5],
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
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                          ),
                        ),
                      ),
                    ),
                  )
                : selected == "Text"
                    ? ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.dataPoints[0].length,
                        itemBuilder: (context, index) {
                          if (stickyScroll) {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            });
                          }
                          print(widget.dataPoints);
                          return ListTile(
                            title: Row(
                              children: widget.dataPoints
                                  .map((e) =>
                                      Expanded(child: Text(e[index].name)))
                                  .toList(),
                            ),
                            subtitle: Row(
                              children: widget.dataPoints
                                  .map((e) => Expanded(
                                      child: Text(e[index].value.toString())))
                                  .toList(),
                            ),
                          );
                        },
                      )
                    : Container(
                        child: Builder(
                          builder: (context) {
                            if (plane == null) {
                              return Center(child: CircularProgressIndicator());
                            }
                            controller?.update(
                              rotationY: widget.dataPoints[0].lastOrNull!.value,
                              rotationX: widget.dataPoints[1].lastOrNull!.value,
                              rotationZ:
                                  widget.dataPoints[2].lastOrNull!.value * -1,
                            );

                            return DiTreDi(
                                figures: [plane!], controller: controller!);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
