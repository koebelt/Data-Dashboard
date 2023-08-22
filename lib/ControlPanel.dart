import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  TextEditingController commandController = TextEditingController();
  FocusNode commandFocusNode = FocusNode();
  bool commandHasFocus = false;
  ScrollController scrollController = ScrollController();
  List<String> commands = [];

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  commandHasFocus
                      ? Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 10, top: 5, bottom: 5),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          height: commands.isEmpty
                              ? 0
                              : commands.length < 12
                                  ? commands.length * 20 + 10
                                  : 240,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ]),
                          child: ListView.builder(
                            controller: scrollController,
                            scrollDirection: Axis.vertical,
                            itemCount: commands.length,
                            itemBuilder: (context, index) {
                              return Text(commands[index]);
                            },
                          ),
                        )
                      : Container(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      focusNode: commandFocusNode,
                      controller: commandController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none),
                      ),
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
                ],
              ),
            ),
          ),
        ),
        MediaQuery.of(context).orientation == Orientation.landscape
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.9),
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    base: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        // color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    listener: (details) {
                      print(details.x);
                    },
                  ),
                ),
              )
            : Container(),
        MediaQuery.of(context).orientation == Orientation.landscape
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.9),
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    base: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        // color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    listener: (details) {
                      print(details.x);
                    },
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
