import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';

typedef OnNewDataCallback = void Function(List<double> newValues);

class BleService {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final OnNewDataCallback onNewData;
  final String targetDeviceName;

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;

  BleService({
    required this.onNewData,
    required this.targetDeviceName,
  });

  void start() {
    flutterBlue.scan(timeout: const Duration(seconds: 10)).listen((scanResult) async {
      if (scanResult.device.name == targetDeviceName) {
        print('Нашёл устройство: $targetDeviceName');
        await flutterBlue.stopScan();
        targetDevice = scanResult.device;
        await targetDevice!.connect();
        await discoverServices();
      }
    });
  }

  Future<void> discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice!.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.notify) {
          targetCharacteristic = char;
          await char.setNotifyValue(true);
          char.value.listen((value) {
            final stringData = utf8.decode(value);
            final numbers = parseStringToDoubleList(stringData);
            if (numbers.isNotEmpty) {
              onNewData(numbers);
            }
          });
        }
      }
    }
  }

  List<double> parseStringToDoubleList(String data) {
    try {
      return data
          .split(' ')
          .map((e) => double.tryParse(e.trim()))
          .whereType<double>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
