import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

typedef OnNewDataCallback = void Function(List<double> newValues);

class BleService {
  final OnNewDataCallback onNewData;
  final String targetDeviceName;

  BluetoothDevice? _targetDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription<List<int>>? _valueSubscription;

  BleService({
    required this.onNewData,
    required this.targetDeviceName,
  });

  void startScan() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.platformName == targetDeviceName) {
          print("Найдено устройство: ${result.device.platformName}");
          _stopScan();
          _targetDevice = result.device;
          _connectToDevice();
          break;
        }
      }
    });

    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }

  Future<void> _connectToDevice() async {
    if (_targetDevice == null) return;

    try {
      await _targetDevice!.connect(autoConnect: false);
      print("Подключено к ${_targetDevice!.platformName}");
      await _discoverServices();
    } catch (e) {
      print("Ошибка подключения: $e");
    }
  }

  Future<void> _discoverServices() async {
    if (_targetDevice == null) return;

    try {
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().startsWith('180')) {
          continue;
        }
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          while (true) {
            await Future.delayed(Duration(seconds: 1));
            if (characteristic.properties.read) {
              print(characteristic.properties);
              try {
                List<int> value = await characteristic.read();
                if (value.isNotEmpty) {
                  String stringData = utf8.decode(value);
                  print("Прочитано: $stringData");
                  _handleIncomingData(stringData);
                }
              } catch (e) {
                print("Ошибка чтения: $e");
              }
            }
          }
        }
      }
    } catch (e) {
      print("Ошибка при поиске сервисов: $e");
    }
  }

  void _handleIncomingData(String stringData) {
    final numbers = _parseStringToDoubleList(stringData);
    onNewData(numbers);
  }

  List<double> _parseStringToDoubleList(String data) {
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

  Future<void> dispose() async {
    await _valueSubscription?.cancel();
    await _scanSubscription?.cancel();
    await _targetDevice?.disconnect();
  }
}