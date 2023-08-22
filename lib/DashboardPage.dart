import 'package:flutter/material.dart';
import 'DeviceIcon.dart';
import 'Device.dart';
import 'Dashboard.dart';
import 'package:fl_chart/fl_chart.dart';
import "Data.dart";
import 'ControlPanel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Device? device;
  Stream<String>? dataStream;
  Map<String, List<List<Data>>> dataMap = {};
  Map<String, List<FlSpot>> visibleDataMap = {};
  Map<String, DashboardItem> graphs = {};
  TextEditingController commandController = TextEditingController();
  FocusNode commandFocusNode = FocusNode();
  bool commandHasFocus = false;
  ScrollController scrollController = ScrollController();
  List<String> commands = [];

  setDevice(Device? device) {
    setState(() {
      dataMap.clear();
      visibleDataMap.clear();
      this.device = device;
      if (this.device == null) {
        Navigator.pop(context);
        return;
      }
      this.device!.connect().then((_) {
        dataStream = device?.readData();
        Navigator.pop(context);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    commandFocusNode.addListener(() {
      setState(() {
        commandHasFocus = commandFocusNode.hasFocus;
        scrollDown();
      });
    });
  }

  Future scrollDown() async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (commandHasFocus) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    }
  }

  void parseReceivedData(String receivedString) {
    int startIndex = receivedString.indexOf('!');
    int endIndex = receivedString.indexOf('\n', startIndex + 1);

    if (startIndex != -1 && endIndex != -1) {
      String line = receivedString.substring(startIndex + 1, endIndex - 1);

      List<String> parts = line.split('?');
      if (parts.length == 2) {
        double? index = double.tryParse(parts[0]);
        if (index != null) {
          // print(parts[1]);
          final regex = RegExp(r'(\w+):(-?[0-9.]+);');
          final groupRegex = RegExp(r'(\w+):\((\S+)+\)');
          final insideRegex = RegExp(r'(\w+):(-?[0-9.]+),');

          Iterable<Match> matches = regex.allMatches(parts[1]);
          Iterable<Match> groupMatches = groupRegex.allMatches(parts[1]);

          for (Match match in groupMatches) {
            String key = match.group(1)!;
            String group = match.group(2)!;
            Iterable<Match> insideMatches = insideRegex.allMatches(group);
            List<Data> insideValues = [];
            dataMap[key] = dataMap[key] ?? [];
            for (Match insideMatch in insideMatches) {
              String insideKey = insideMatch.group(1)!;
              double? insideValue = double.tryParse(insideMatch.group(2)!);
              if (insideValue != null) {
                insideValues.add(Data(insideKey, insideValue, index));
              }
            }
            int i = 0;
            for (Data data in insideValues) {
              dataMap[key]!.length <= i
                  ? dataMap[key]!.add([data])
                  : dataMap[key]![i].add(data);
              i++;
            }
          }
          for (Match match in matches) {
            String key = match.group(1)!;
            double? value = double.tryParse(match.group(2)!);
            if (value != null) {
              dataMap[key] = dataMap[key] ?? [];
              dataMap[key]!.isEmpty
                  ? dataMap[key]!.add([Data(key, value, index)])
                  : dataMap[key]![0].add(Data(key, value, index));
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: StreamBuilder<String>(
            stream: dataStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Awaiting result...');
              }
              // print(snapshot!.data);
              if (snapshot.data != null) {
                parseReceivedData(snapshot.data!);
              }

              return SingleChildScrollView(
                child: Dashboard(
                  items: dataMap.keys
                      .map(
                        (e) => DashboardItem(
                          title: e,
                          dataPoints: dataMap[e]!,
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DeviceIcon(device: device, setDevice: setDevice),
            ],
          ),
        ),
        const ControlPanel(),
      ],
    );
  }
}
