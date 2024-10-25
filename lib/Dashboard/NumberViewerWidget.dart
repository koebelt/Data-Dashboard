import 'package:flutter/material.dart';

class NumberViewerWidget extends StatefulWidget {
  const NumberViewerWidget({super.key, required this.number, this.unit});

  final num number;
  final String? unit;

  @override
  State<NumberViewerWidget> createState() => _NumberViewerWidgetState();
}

class _NumberViewerWidgetState extends State<NumberViewerWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            widget.number.toStringAsFixed(2),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.surface,
                ),
          ),
          if (widget.unit != null)
            Text(
              widget.unit!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.surfaceBright),
            ),
        ],
      ),
    );
  }
}
