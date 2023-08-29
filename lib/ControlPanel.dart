import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'Data.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key, required this.setting});

  final Setting setting;

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel>
    with SingleTickerProviderStateMixin {
  TextEditingController commandController = TextEditingController();
  FocusNode commandFocusNode = FocusNode();
  FocusNode terminalFocusNode = FocusNode();
  bool commandHasFocus = false;
  ScrollController scrollController = ScrollController();
  List<String> commands = [];
  late AnimationController _animationController;
  double animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: animationValue,
      vsync: this,
    );
    _animationController.addListener(() {
      setState(() {
        animationValue = _animationController.value;
      });
    });

    commandFocusNode.addListener(() {
      setState(() {
        commandHasFocus =
            terminalFocusNode.hasFocus || commandFocusNode.hasFocus;
        _animationController.animateTo(commandHasFocus ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
        // scrollDown();
      });
    });
    // terminalFocusNode.addListener(() {
    //   setState(() {
    //     commandHasFocus = terminalFocusNode.hasFocus;
    //   });
    // });
  }

  Future scrollDown() async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (commandHasFocus) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        !widget.setting.hasCommand && !widget.setting.hasJoysticks
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CurvedPathPainter(animationValue),
                    // painter: ControlPanelCustomPainter(hasFocus: commandHasFocus),
                    child: Container(height: 250),
                  ),
                ),
              ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width > 900
                  ? MediaQuery.of(context).size.width * 0.8 - 300
                  : MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 36, 34, 37),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 22, 21, 22),
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20, right: 10, top: 5, bottom: 5),
                    height: 270 * animationValue,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: commands.length,
                      itemBuilder: (context, index) {
                        return SelectableText(
                          commands[index],
                          focusNode: terminalFocusNode,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        );
                      },
                    ),
                  ),
                  widget.setting.hasCommand
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            focusNode: commandFocusNode,
                            controller: commandController,
                            decoration: InputDecoration(
                              hintText: 'Enter command',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none),
                            ),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            keyboardType: TextInputType.text,
                            onSubmitted: (value) {
                              print(value);
                              commandController.text = "";
                              commandFocusNode.requestFocus();
                              setState(() {
                                commands.add(value);
                              });
                              scrollDown();
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        widget.setting.hasJoysticks
            ? MediaQuery.of(context).size.width > 900
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Joystick(
                        stick: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        base: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        listener: (details) {
                          print(details.x);
                        },
                      ),
                    ),
                  )
                : Container()
            : Container(),
        widget.setting.hasJoysticks
            ? MediaQuery.of(context).size.width > 900
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Joystick(
                        stick: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        base: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        listener: (details) {
                          print(details.x);
                        },
                      ),
                    ),
                  )
                : Container()
            : Container(),
      ],
    );
  }
}

class CurvedPathPainter extends CustomPainter {
  final double animationValue;

  CurvedPathPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    double curve1avancement = animationValue;
    double curve2avancement = 1 - animationValue;

    final path;

    if (size.width > 900) {
      path = Path()
        ..moveTo(0, 0)
        ..lineTo(100 * curve1avancement + 75 * curve2avancement, 0)
        ..cubicTo(
            (100 + 100) * curve1avancement + (75 + 200) * curve2avancement,
            0,
            (100 + 100) * curve1avancement + (75 + 200) * curve2avancement,
            -120 * curve1avancement + 150 * curve2avancement,
            (100 + 200) * curve1avancement + (75 + 350) * curve2avancement,
            -120 * curve1avancement + 150 * curve2avancement)
        ..lineTo(
            size.width -
                (100 + 200) * curve1avancement -
                (75 + 350) * curve2avancement,
            -120 * curve1avancement + 150 * curve2avancement)
        ..cubicTo(
            size.width -
                (100 + 100) * curve1avancement -
                (75 + 200) * curve2avancement,
            -120 * curve1avancement + 150 * curve2avancement,
            size.width -
                (100 + 100) * curve1avancement -
                (75 + 200) * curve2avancement,
            0,
            size.width - 100 * curve1avancement - 75 * curve2avancement,
            0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path = Path()
        ..moveTo(0, size.height * curve2avancement)
        ..cubicTo(
            25,
            0 + size.height * curve2avancement,
            25,
            -120 * curve1avancement + 150 * curve2avancement,
            100,
            -120 * curve1avancement + 150 * curve2avancement)
        ..lineTo(
            size.width - 100, -120 * curve1avancement + 150 * curve2avancement)
        ..cubicTo(
            size.width - 25,
            -120 * curve1avancement + 150 * curve2avancement,
            size.width - 25,
            0 + size.height * curve2avancement,
            size.width,
            0 + size.height * curve2avancement)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    final paint = Paint()
      ..color = Color.fromARGB(255, 36, 34, 37)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Color.fromARGB(255, 22, 21, 22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
