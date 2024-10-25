import 'package:data_dashboard/Dashboard/DashboardTileWidget.dart';
import 'package:data_dashboard/Dashboard/MapViewerWidget.dart';
import 'package:data_dashboard/Dashboard/NumberViewerWidget.dart';
import 'package:data_dashboard/Dashboard/NumericalViewerWidget.dart';
import 'package:data_dashboard/Dashboard/TreeDViewerWidget.dart';
import 'package:data_dashboard/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

extension LayoutProvider on StaggeredGrid {
  static StaggeredGrid fromData({
    required BuildContext context,
    required DataList dataList,
  }) {
    return StaggeredGrid.count(
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      crossAxisCount: _getCrossAxisCount(context),
      children: _layoutBuilder(context, dataList),
    );
  }
}

int _getCrossAxisCount(BuildContext context) {
  if (MediaQuery.of(context).size.width < 600) {
    return 2;
  } else if (MediaQuery.of(context).size.width < 900) {
    return 3;
  } else if (MediaQuery.of(context).size.width < 1200) {
    return 4;
  } else {
    return 6;
  }
}

int _getBigItemWidth(BuildContext context) {
  if (MediaQuery.of(context).size.width < 600) {
    return 2;
  } else if (MediaQuery.of(context).size.width < 900) {
    return 2;
  } else if (MediaQuery.of(context).size.width < 1200) {
    return 2;
  } else {
    return 4;
  }
}

int _getSmallItemWidth(BuildContext context) {
  if (MediaQuery.of(context).size.width < 600) {
    return 1;
  } else if (MediaQuery.of(context).size.width < 900) {
    return 1;
  } else if (MediaQuery.of(context).size.width < 1200) {
    return 1;
  } else {
    return 2;
  }
}

List<Widget> _layoutBuilder(BuildContext context, DataList dataList) {
  List<Widget> widgets = [];

  for (Map<int, Data> data in dataList.dataList) {
    // take highest key in the map
    int timestamp =
        data.keys.reduce((value, element) => value > element ? value : element);
    Data value = data[timestamp]!;

    if (value is DataLocation) {
      widgets.add(_locationDataMap(context, value));
    } else if (value is DataPosition) {
      Widget? widget =
          _positionData3DViewer(context, dataList.dataList, position: value);
      if (widget != null) {
        widgets.add(widget);
      }
    } else if (value is DataRotation) {
      Widget? widget =
          _positionData3DViewer(context, dataList.dataList, rotation: value);
      if (widget != null) {
        widgets.add(widget);
      }
    } else if (value is DataTemperature) {
      widgets.add(_numericalData(context, data));
    } else if (value is DataHumidity) {
      widgets.add(_numericalData(context, data));
    } else if (value is DataPressure) {
      widgets.add(_numericalData(context, data));
    } else if (value is DataAcceleration) {
      widgets.add(_numericalData(context, data));
    } else if (value is DataAngularVelocity) {
      widgets.add(_numericalData(context, data));
    } else if (value is DataString) {
      widgets.add(_rawData(context, value));
    }
  }
  return widgets;
}

Widget? _positionData3DViewer(
    BuildContext context, List<Map<int, Data<dynamic>>> dataList,
    {DataPosition? position, DataRotation? rotation}) {
  if (position != null) {
    int index_position = -1;
    int index_rotation = -1;

    for (Map<int, Data> data in dataList) {
      int timestamp = data.keys
          .reduce((value, element) => value > element ? value : element);
      Data value = data[timestamp]!;
      if (value is DataRotation) {
        index_rotation = dataList.indexOf(data);
        if (index_position != -1) {
          return DashboardTileWidget(
            child: TreeDViewerWidget(
                // dataList: dataList,
                // position: position,
                rotation: Vector3(
              value.value.yaw,
              value.value.pitch,
              value.value.roll,
            )),
            height: 2,
            width: _getBigItemWidth(context),
          );
        } else {
          return null;
        }
      }
      if (value is DataPosition) {
        index_position = dataList.indexOf(data);
      }
    }
    return DashboardTileWidget(
      child: TreeDViewerWidget(
          // position: position,
          ),
      height: 2,
      width: _getBigItemWidth(context),
    );
  } else if (rotation != null) {
    int index_position = -1;
    int index_rotation = -1;

    for (Map<int, Data> data in dataList) {
      int timestamp = data.keys
          .reduce((value, element) => value > element ? value : element);
      Data value = data[timestamp]!;
      if (value is DataPosition) {
        index_position = dataList.indexOf(data);
        if (index_rotation != -1) {
          return DashboardTileWidget(
            child: TreeDViewerWidget(
                // dataList: dataList,
                // position: value,
                // rotation: rotation,
                ),
            height: 2,
            width: _getBigItemWidth(context),
          );
        } else {
          return null;
        }
      }
      if (value is DataRotation) {
        index_rotation = dataList.indexOf(data);
      }
    }
    return DashboardTileWidget(
      child: TreeDViewerWidget(
          // rotation: rotation,
          ),
      height: 2,
      width: _getBigItemWidth(context),
    );
  } else {
    return null;
  }
}

Widget _locationDataMap(BuildContext context, DataLocation value) {
  return DashboardTileWidget(
      child: MapViewerWidget(
        location: value,
      ),
      height: 2,
      width: _getBigItemWidth(context));
}

Widget _numericalData(BuildContext context, Map<int, Data> value) {
  return DashboardTileWidget(
    color: Theme.of(context).colorScheme.secondary,
    child: NumericalViewerWidget(
      data: value.entries.last.value,
    ),
    width: _getSmallItemWidth(context),
  );
}

Widget _rawData(BuildContext context, Data value) {
  if (value.runtimeType == DataString) {
    return DashboardTileWidget(
      color: Theme.of(context).colorScheme.secondary,
      child: Center(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            value.value as String,
            style: TextStyle(
              fontSize: 42,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ),
      width: _getSmallItemWidth(context),
    );
  }
  return DashboardTileWidget(
    child: Container(),
    width: _getSmallItemWidth(context),
  );
}
