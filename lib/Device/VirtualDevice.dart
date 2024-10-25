import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:data_dashboard/Device/Device.dart';

class VirtualDevice extends Device {
  late StreamController<List<int>> _dataStreamController;
  late Timer _sinusoidTimer;
  double x = 0.0;
  int index = 0;

  VirtualDevice();

  @override
  Future<void> connect() async {
    // Initialize the data stream controller
    _dataStreamController = StreamController<List<int>>();

    // Start generating and sending sinusoidal waveform after a connection is established
    _sinusoidTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      Map<String, dynamic> data = {
        "timestamp": index,
        "data": [
          {
            "Location": {
              "latitude": 48.5833 + sin(x) * 0.0001,
              "longitude": 7.75 + cos(x) * 0.0001,
              "altitude": cos(x + 1)
            }
          },
          {
            "Position": {"x": sin(x), "y": cos(x), "z": cos(x + 1)}
          },
          {
            "Rotation": {"yaw": sin(x), "pitch": cos(x), "roll": cos(x + 1)}
          },
          {
            "Temperature": {"temperature": sin(x)}
          },
          {
            "Humidity": {"humidity": cos(x)}
          },
          {
            "Pressure": {"pressure": cos(x + 1)}
          },
          {
            "Acceleration": {"x": sin(x), "y": cos(x), "z": cos(x + 1)}
          },
          {
            "AngularVelocity": {
              "yaw": sin(x),
              "pitch": cos(x),
              "roll": cos(x + 1)
            }
          }
        ]
      };
      _dataStreamController.add(cborEncode(CborValue(data)));
      x += 0.05;
      index++;
    });
  }

  @override
  Future<void> disconnect() async {
    // Stop the sinusoid generation timer
    _sinusoidTimer.cancel();

    // Close the data stream controller
    await _dataStreamController.close();

    print('VirtualDevice disconnected.');
  }

  @override
  Stream<List<int>> readData() {
    return _dataStreamController.stream;
  }

  @override
  void writeData(Uint8List data) {
    throw UnimplementedError();
  }

  @override
  String getType() {
    return 'Virtual';
  }

  @override
  String getName() {
    return 'Emulated Device';
  }
}
