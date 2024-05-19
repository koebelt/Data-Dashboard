import 'package:data_dashboard/Dashboard/DashboardPage.dart';
import 'package:data_dashboard/PageWidget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _pushToDashboard() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()));
  }

  @override
  void initState() {
    super.initState();
    _pushToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
