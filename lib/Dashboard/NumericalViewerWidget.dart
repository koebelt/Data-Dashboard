import 'package:data_dashboard/Data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NumericalViewerWidget extends StatefulWidget {
  const NumericalViewerWidget({super.key, required this.data});

  final Data data;

  @override
  State<NumericalViewerWidget> createState() => _NumericalViewerWidgetState();
}

enum NumericalViewerType {
  NUMBER,
  GRAPH,
}

class _NumericalViewerWidgetState extends State<NumericalViewerWidget> {
  NumericalViewerType viewerType = NumericalViewerType.NUMBER;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 0,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (viewerType == NumericalViewerType.NUMBER) {
                  viewerType = NumericalViewerType.GRAPH;
                } else {
                  viewerType = NumericalViewerType.NUMBER;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(5),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
            child: Icon(
              viewerType == NumericalViewerType.NUMBER
                  ? Icons.numbers
                  : Icons.auto_graph_rounded,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        if (viewerType == NumericalViewerType.NUMBER)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (() {
                    switch (widget.data.runtimeType) {
                      case DataPosition:
                        return "x:" +
                            (widget.data as DataPosition)
                                .value
                                .x
                                .toStringAsFixed(2) +
                            " y:" +
                            (widget.data as DataPosition)
                                .value
                                .y
                                .toStringAsFixed(2) +
                            " z:" +
                            (widget.data as DataPosition)
                                .value
                                .z
                                .toStringAsFixed(2);
                      case DataAcceleration:
                        return "x:" +
                            (widget.data as DataAcceleration)
                                .value
                                .x
                                .toStringAsFixed(2) +
                            " y:" +
                            (widget.data as DataAcceleration)
                                .value
                                .y
                                .toStringAsFixed(2) +
                            " z:" +
                            (widget.data as DataAcceleration)
                                .value
                                .z
                                .toStringAsFixed(2);
                      case DataRotation:
                        return "yaw:" +
                            (widget.data as DataRotation)
                                .value
                                .yaw
                                .toStringAsFixed(2) +
                            " pitch:" +
                            (widget.data as DataRotation)
                                .value
                                .pitch
                                .toStringAsFixed(2) +
                            " roll:" +
                            (widget.data as DataRotation)
                                .value
                                .roll
                                .toStringAsFixed(2);
                      case DataAngularVelocity:
                        return "yaw:" +
                            (widget.data as DataAngularVelocity)
                                .value
                                .yaw
                                .toStringAsFixed(2) +
                            " pitch:" +
                            (widget.data as DataAngularVelocity)
                                .value
                                .pitch
                                .toStringAsFixed(2) +
                            " roll:" +
                            (widget.data as DataAngularVelocity)
                                .value
                                .roll
                                .toStringAsFixed(2);
                      default:
                        return widget.data.value.toStringAsFixed(2);
                    }
                  }()),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                ),
                Text(
                  (() {
                    switch (widget.data.runtimeType) {
                      case DataTemperature:
                        return "°C";
                      case DataPressure:
                        return "Pa";
                      case DataHumidity:
                        return "%";
                      case DataPosition:
                        return "m";
                      default:
                        return "";
                    }
                  }()),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surfaceBright),
                ),
              ],
            ),
          ),
        if (viewerType == NumericalViewerType.GRAPH)
          Center(
            child: Text("Graph"),
          ),
      ],
    );
  }
}
