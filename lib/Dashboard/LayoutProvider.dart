import 'package:data_dashboard/Dashboard/DashboardTileWidget.dart';
import 'package:data_dashboard/Dashboard/TreeDViewerWidget.dart';
import 'package:data_dashboard/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

enum LayoutType {
  PositionData3DViewer,
  LocationDataMap,
  GraphData,
  RawData,
}

extension LayoutProvider on StaggeredGrid {
  static StaggeredGrid fromData(
      {required BuildContext context,
      required DataList dataList,
      required List<LayoutType> layoutTypes}) {
    return StaggeredGrid.count(
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      crossAxisCount: _getCrossAxisCount(context),
      children: _layoutBuilder(context, dataList, layoutTypes),
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

List<Widget> _layoutBuilder(
    BuildContext context, DataList dataList, List<LayoutType> layoutTypes) {
  List<Widget> widgets = [];
  dataList.dataList.forEach((key, value) {
    if (layoutTypes.contains(LayoutType.PositionData3DViewer) &&
        value.first.runtimeType == DataPosition) {
      widgets.add(_positionData3DViewer(context, key, value));
    }
    if (layoutTypes.contains(LayoutType.LocationDataMap) &&
        value.first.runtimeType == DataLocation) {
      widgets.add(_locationDataMap(context, key, value));
    }
    if (layoutTypes.contains(LayoutType.GraphData)) {
      widgets.add(_graphData(context, key, value));
    }
    if (layoutTypes.contains(LayoutType.RawData)) {
      widgets.add(_rawData(context, key, value));
    }
  });
  return widgets;
}

Widget _positionData3DViewer(
    BuildContext context, String key, List<Data> value) {
  return DashboardTileWidget(
      child: TreeDViewerWidget(), height: 2, width: _getBigItemWidth(context));
}

Widget _locationDataMap(BuildContext context, String key, List<Data> value) {
  return DashboardTileWidget(
      child: Container(), height: 2, width: _getBigItemWidth(context));
}

Widget _graphData(BuildContext context, String key, List<Data> value) {
  return DashboardTileWidget(
    child: Container(),
    width: _getSmallItemWidth(context),
  );
}

Widget _rawData(BuildContext context, String key, List<Data> value) {
  return DashboardTileWidget(
    child: Container(),
    width: _getSmallItemWidth(context),
  );
}
