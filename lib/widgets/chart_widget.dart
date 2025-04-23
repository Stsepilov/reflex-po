import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

import '../utils/bluetooth_connection.dart';
import '../utils/check_permission.dart';
import '../utils/test_data.dart';

class PulseChart extends StatefulWidget {
  const PulseChart({super.key});

  @override
  _PulseChartState createState() => _PulseChartState();
}

class _PulseChartState extends State<PulseChart> with SingleTickerProviderStateMixin{
  List<double> values = [];
  late BleService bleService;

  @override
  void initState() {
    super.initState();
    checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bleService = BleService(onNewData: updateValues, targetDeviceName: "MyESP32");
      bleService.startScan();
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   start(updateValues);
    // });
  }

  void updateValues(List<double> newValues) {
    setState(() {
      values.addAll(newValues);
      if (values.length > 500) {
        values = values.sublist(values.length - 500);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String dataJson = jsonEncode(values);
    // print(dataJson);
    // print(List.generate(values.length, (index) => index).length);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Echarts(
          option: '''
          {
            xAxis: {
              type: 'value',
              min: 200,
              max: 4000,
              splitLine: { lineStyle: { color: '#fff' } },
              axisLine: { lineStyle: { color: '#fff' } },
              axisLabel: { 
                color: '#fff',
                rotate: 270
              }
            },
            yAxis: {
              type: 'category',
              data: ${List.generate(values.length, (index) => index)},
              show: false,
              boundaryGap: false,
              inverse: true
            },
            grid: {
              top: 0,
              bottom: 50,
              left: 20,
              right: 20
            },
            series: [{
              data: $dataJson,
              type: 'line',
              smooth: true,
              showSymbol: false,
              lineStyle: { color: '#FFFFFF', width: 2 }
            }],
            animation: true,
            animationDuration: 1000
            }
            ''',
        ),
    );
  }


}