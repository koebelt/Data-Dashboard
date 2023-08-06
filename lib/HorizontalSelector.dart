import 'package:flutter/material.dart';

class HorizontalSelector extends StatefulWidget {
  final List<String> items;
  final Function(String) onChange;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;

  const HorizontalSelector({
    super.key,
    required this.items,
    required this.onChange,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  _HorizontalSelectorState createState() => _HorizontalSelectorState();
}

class _HorizontalSelectorState extends State<HorizontalSelector>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animateToIndex(int index) {
    setState(() {
      selectedIndex = index;
      widget.onChange(widget.items[index]);
    });

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        height: widget.height ?? 40,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height ?? 40),
          color: Colors.grey.shade400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final itemWidth = constraints.maxWidth / widget.items.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    left: (selectedIndex * itemWidth),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: itemWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(widget.height ?? 40),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.items.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            animateToIndex(index);
                          },
                          child: Container(
                            height: widget.height ?? 40,
                            constraints: const BoxConstraints(
                              minWidth: 50,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(widget.height ?? 40),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(widget.items[index],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
