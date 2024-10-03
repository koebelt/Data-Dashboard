import 'package:cbor/cbor.dart';
import 'dart:typed_data';

class DataList {
  List<Map<int, Data>> dataList;

  DataList({
    required this.dataList,
  });

  factory DataList.fromBytes(List<int> bytes) {
    var decoded = cbor.decode(Uint8List.fromList(bytes));
    return DataList.fromJson(decoded.toJson() as Map<String, dynamic>);
  }

  factory DataList.fromJson(Map<String, dynamic> json) {
    List<Map<int, Data>> dataList = [];
    for (Map<String, dynamic> value in json["data"]) {
      // example data
      // {Location: {latitude: 37.7749, longitude: 122.4194, altitude: 0.0}}
      // {Position: {x: 0.0, y: 0.0, z: 0.0}}
      // {Rotation: {yaw: 0.0, pitch: 0.0, roll: 0.0}}
      // {Temperature: {temperature: 0.0}}
      // {Humidity: {humidity: 0.0}}
      // {Pressure: {pressure: 0.0}}
      value.forEach((key, value) {
        switch (key) {
          case "Location":
            dataList.add({
              json["timestamp"]: DataLocation(
                  value: Location(
                      latitude: value["latitude"],
                      longitude: value["longitude"],
                      altitude: value["altitude"]))
            });
            break;
          case "Position":
            dataList.add({
              json["timestamp"]: DataPosition(
                  value: Position(x: value["x"], y: value["y"], z: value["z"]))
            });
            break;
          case "Rotation":
            dataList.add({
              json["timestamp"]: DataRotation(
                  value: Rotation(
                      yaw: value["yaw"],
                      pitch: value["pitch"],
                      roll: value["roll"]))
            });
            break;
          case "Temperature":
            dataList.add({
              json["timestamp"]: DataTemperature(value: value["temperature"])});
            break;
          case "Humidity":
            dataList.add({json["timestamp"]: DataHumidity(value: value["humidity"])});
            break;
          case "Pressure":
            dataList.add({json["timestamp"]: DataPressure(value: value["pressure"])});
            break;
          case "Acceleration":
            dataList.add({
              json["timestamp"]: DataAcceleration(
                  value: Position(x: value["x"], y: value["y"], z: value["z"]))
            });
            break;
          case "AngularVelocity":
            dataList.add({
              json["timestamp"]: DataAngularVelocity(
                  value: Rotation(
                      yaw: value["yaw"],
                      pitch: value["pitch"],
                      roll: value["roll"]))
            });
            break;
          default:
            throw Exception("Invalid data type");
        }
      });
    }
    return DataList(dataList: dataList);
  }
}

abstract class Data<T> {
  T value;
  Data({required this.value});
}

class DataString extends Data<String> {
  DataString({required String value}) : super(value: value);
}

class Location {
  double latitude;
  double longitude;
  double altitude;

  Location(
      {required this.latitude, required this.longitude, this.altitude = 0.0});
}

class DataLocation extends Data<Location> {
  DataLocation({required Location value}) : super(value: value);
}

class Position {
  double x;
  double y;
  double z;

  Position({required this.x, required this.y, required this.z});
}

class DataPosition extends Data<Position> {
  DataPosition({required Position value}) : super(value: value);
}

class Rotation {
  double yaw;
  double pitch;
  double roll;

  Rotation({required this.yaw, required this.pitch, required this.roll});
}

class DataRotation extends Data<Rotation> {
  DataRotation({required Rotation value}) : super(value: value);
}

class DataTemperature extends Data<double> {
  DataTemperature({required double value}) : super(value: value);
}

class DataPressure extends Data<double> {
  DataPressure({required double value}) : super(value: value);
}

class DataHumidity extends Data<double> {
  DataHumidity({required double value}) : super(value: value);
}

class DataAcceleration extends Data<Position> {
  DataAcceleration({required Position value}) : super(value: value);
}

class DataAngularVelocity extends Data<Rotation> {
  DataAngularVelocity({required Rotation value}) : super(value: value);
}
