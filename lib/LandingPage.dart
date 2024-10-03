import 'package:data_dashboard/LandingAnimationWidget.dart';
import 'package:ditredi/ditredi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 900 ? 100 : 20,
          vertical: 20),
      child: Column(
        children: [
          const Text("Landing Page"),
          LandingAnimationWidget(),
        ],
      ),
    );
  }
}
