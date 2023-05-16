import 'package:flutter/material.dart';

class DashboardItem extends StatefulWidget {
  const DashboardItem({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<DashboardItem> createState() => _DashboardItemState();
}

class _DashboardItemState extends State<DashboardItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(2, 10), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Wrap(
            children: [
              Text(widget.title),
              widget.child,
            ],
          )
        ),
      ),
    );
  }
}