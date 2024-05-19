class DataList {
  Map<String, List<Data>> dataList;

  DataList({
    required this.dataList,
  });

  factory DataList.fromMap(Map<String, dynamic> data) {
    Map<String, List<Data>> dataList = {};
    data.forEach((key, value) {
      List<Data> dataListValue = [];
      if (value.runtimeType == double) {
        dataListValue.add(DataDouble(value: value));
      } else if (value.runtimeType == String) {
        dataListValue.add(DataString(value: value));
      } else if (value.runtimeType == bool) {
        dataListValue.add(DataBool(value: value));
      } else if (value.runtimeType == int) {
        dataListValue.add(DataInt(value: value));
      } else if (value.runtimeType.toString() == "_Map<String, double>") {
        if ((value.containsKey('latitude') && value.containsKey('longitude'))) {
          dataListValue.add(DataLocation(
              value: Location(
                  latitude: value['latitude'], longitude: value['longitude'])));
        } else if (value.containsKey('x') &&
            value.containsKey('y') &&
            value.containsKey('z')) {
          dataListValue.add(DataPosition(
              value: Position(x: value['x'], y: value['y'], z: value['z'])));
        }
      }
      dataList[key] = dataListValue;
    });
    return DataList(dataList: dataList);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    dataList.forEach((key, value) {
      List<dynamic> dataListValue = [];
      value.forEach((element) {
        if (element is DataDouble) {
          dataListValue.add(element.value);
        } else if (element is DataString) {
          dataListValue.add(element.value);
        } else if (element is DataBool) {
          dataListValue.add(element.value);
        } else if (element is DataInt) {
          dataListValue.add(element.value);
        } else if (element is DataLocation) {
          dataListValue.add({
            'latitude': element.value.latitude,
            'longitude': element.value.longitude
          });
        } else if (element is DataPosition) {
          dataListValue.add({
            'x': element.value.x,
            'y': element.value.y,
            'z': element.value.z
          });
        }
      });
      data[key] = dataListValue;
    });

    return data;
  }

  void addData(String key, Data data) {
    if (dataList.containsKey(key)) {
      dataList[key]!.add(data);
    } else {
      dataList[key] = [data];
    }
  }

  void addDataMap(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value.runtimeType == double) {
        addData(key, DataDouble(value: value));
      } else if (value.runtimeType == String) {
        addData(key, DataString(value: value));
      } else if (value.runtimeType == bool) {
        addData(key, DataBool(value: value));
      } else if (value.runtimeType == int) {
        addData(key, DataInt(value: value));
      } else if (value.runtimeType == Map<String, dynamic>) {
        if ((value.containsKey('latitude') && value.containsKey('longitude'))) {
          addData(
              key,
              DataLocation(
                  value: Location(
                      latitude: value['latitude'],
                      longitude: value['longitude'])));
        } else if (value.containsKey('x') &&
            value.containsKey('y') &&
            value.containsKey('z')) {
          addData(
              key,
              DataPosition(
                  value:
                      Position(x: value['x'], y: value['y'], z: value['z'])));
        }
      }
    });
  }
}

abstract class Data<T> {
  T value;

  Data({required this.value});
}

// Specific Data subclasses for different types
class DataDouble extends Data<double> {
  DataDouble({required double value}) : super(value: value);
}

class DataString extends Data<String> {
  DataString({required String value}) : super(value: value);
}

class DataBool extends Data<bool> {
  DataBool({required bool value}) : super(value: value);
}

class DataInt extends Data<int> {
  DataInt({required int value}) : super(value: value);
}

// Class representing a geographic location
class Location {
  double latitude;
  double longitude;

  Location({required this.latitude, required this.longitude});
}

// Data subclass for Location
class DataLocation extends Data<Location> {
  DataLocation({required Location value}) : super(value: value);
}

// Class representing a 3D position
class Position {
  double x;
  double y;
  double z;

  Position({required this.x, required this.y, required this.z});
}

// Data subclass for Position
class DataPosition extends Data<Position> {
  DataPosition({required Position value}) : super(value: value);
}
