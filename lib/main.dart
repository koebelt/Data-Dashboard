import 'package:data_dashboard/DashboardPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DataDashboard());
}

class DataDashboard extends StatefulWidget {
  const DataDashboard({super.key});

  @override
  State<DataDashboard> createState() => _DataDashboardState();
}

class _DataDashboardState extends State<DataDashboard> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff222426)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: DashboardPage(),
      )
      
    );
  }
}

