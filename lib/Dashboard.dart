import 'package:flutter/material.dart';
import "Data.dart";
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ditredi/ditredi.dart';

class Dashboard extends StatelessWidget {
  final List<DashboardItem> items;

  const Dashboard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: StaggeredGrid.count(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        axisDirection: AxisDirection.down,
        children: items,
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    // You can customize the number of columns based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2; // default number of columns

    if (screenWidth > 1300) {
      crossAxisCount = 6; // use 6 columns for large screens
    } else if (screenWidth > 1000) {
      crossAxisCount = 4; // use 4 columns for larger screens
    } else if (screenWidth > 700) {
      crossAxisCount = 3; // use 3 columns for medium screens
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
  String selected = 'Simple Text';
  bool stickyScroll = false;
  final ScrollController _scrollController = ScrollController();
  DiTreDiController? controller;
  Mesh3D? plane;
  int sizex = 1;
  int sizey = 1;

  Future initPlane() async {
    Mesh3D plane2 =
        Mesh3D(await ObjParser().loadFromFile(Uri.parse("assets/plane.obj")));
    setState(() {
      plane = plane2;
    });
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
    });
    controller = DiTreDiController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(
      () {
        if (selected == "Simple Text") {
          sizey = 1;
          sizex = widget.dataPoints.length;
        }
      },
    );
    return StaggeredGridTile.count(
      crossAxisCellCount: sizex,
      mainAxisCellCount: sizey,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color.fromARGB(255, 36, 34, 37),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 22, 21, 22),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                Align(
                  alignment: Alignment.topRight,
                  // child: Padding(
                  // padding: EdgeInsets.only(left: 10, top: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        icon: const Icon(Icons.more_vert),
                        items: [
                          const DropdownMenuItem(
                            value: 'Graph',
                            child: Text('Graph'),
                          ),
                          const DropdownMenuItem(
                            value: 'Text',
                            child: Text('Text'),
                          ),
                          const DropdownMenuItem(
                            value: "Simple Text",
                            child: Text("Simple Text"),
                          ),
                          if (widget.dataPoints.length == 3)
                            const DropdownMenuItem(
                              value: '3D',
                              child: Text('3D'),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selected = value.toString();
                            if (value == '3D') {
                              initPlane();

                              sizey = 3;
                              sizex = 3;
                            } else if (value == 'Simple Text') {
                              sizey = 1;
                              sizex = widget.dataPoints.length;
                            } else if (value == 'Text') {
                              sizey = 2;
                              sizex = widget.dataPoints.length;
                            } else {
                              sizey = 2;
                              sizex = 2;
                            }
                          });
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selected == 'Graph'
                  ? LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(enabled: false),
                        lineBarsData: [
                          for (var i = 0; i < widget.dataPoints.length; i++)
                            LineChartBarData(
                              spots: widget.dataPoints[i]
                                  .sublist(widget.dataPoints[i].length > 400
                                      ? widget.dataPoints[i].length - 400
                                      : 0)
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
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              });
                            }
                            // print(widget.dataPoints);
                            return ListTile(
                              title: Row(
                                children: widget.dataPoints
                                    .map((e) => Expanded(
                                            child: SelectableText(
                                          e[index].name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        )))
                                    .toList(),
                              ),
                              subtitle: Row(
                                children: widget.dataPoints
                                    .map(
                                      (e) => Expanded(
                                        child: SelectableText(
                                          e[index].value.toStringAsFixed(5),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        )
                      : selected == "Simple Text"
                          ? Row(
                              children: [
                                for (var i = 0;
                                    i < widget.dataPoints.length;
                                    i++)
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            widget
                                                .dataPoints[i].lastOrNull!.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            )),
                                        Text(
                                          widget.dataPoints[i].lastOrNull!.value
                                              .toStringAsFixed(3),
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                          : Builder(
                              builder: (context) {
                                if (plane == null) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                controller?.update(
                                  userScale: 1.5,
                                  rotationX:
                                      widget.dataPoints[1].lastOrNull!.value +
                                          90,
                                  rotationY:
                                      widget.dataPoints[2].lastOrNull!.value +
                                          180,
                                  rotationZ:
                                      widget.dataPoints[0].lastOrNull!.value,
                                );

                                return DiTreDi(
                                    figures: [plane!], controller: controller!);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
