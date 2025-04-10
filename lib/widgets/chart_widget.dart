import 'package:flutter/material.dart';

import '../animation/chart_animation.dart';
import '../utils/bluetooth_connection.dart';
import '../utils/chart_list_of_values.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bleService = BleService(onNewData: updateValues, targetDeviceName: "MyESP32");
      bleService.start();
    });
  }

  void updateValues(List<double> newValues) {
    setState(() {
      values.addAll(newValues);
      if (values.length > 100) {
        values.removeAt(0);
      }
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