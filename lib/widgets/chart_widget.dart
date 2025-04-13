import 'package:flutter/material.dart';

import '../animation/chart_animation.dart';
import '../utils/bluetooth_connection.dart';
import '../utils/check_permission.dart';

class PulseChart extends StatefulWidget {
  const PulseChart({super.key});

  @override
  _PulseChartState createState() => _PulseChartState();
}

class _PulseChartState extends State<PulseChart>{
  List<double> values = [];
  late BleService bleService;

  @override
  void initState() {
    super.initState();
    checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bleService = BleService(onNewData: updateValues, targetDeviceName: "MacBook Air — Степан");
      bleService.startScan();
    });
  }

  void updateValues(List<double> newValues) {
    setState(() {
      if (values.length > 100) {
        values = [];
      }
      values.addAll(newValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    double chartHeight = MediaQuery.of(context).size.height * 0.4;
    double chartWidth = MediaQuery.of(context).size.width * 0.75;
    return CustomPaint(
      painter: MyGraphPainter(values),
      child: Container(height: chartHeight, width: chartWidth),
    );
  }


}