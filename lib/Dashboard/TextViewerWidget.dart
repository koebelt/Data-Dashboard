import 'package:flutter/material.dart';

class TextViewerWidget extends StatefulWidget {
  const TextViewerWidget({super.key});

  @override
  State<TextViewerWidget> createState() => _TextViewerWidgetState();
}

class _TextViewerWidgetState extends State<TextViewerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: const Text("Text Viewer"),
    );
  }
}