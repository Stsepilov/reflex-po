import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

typedef OnNewDataCallback = void Function(List<double> newValues);

class BleService {
  final OnNewDataCallback onNewData;
  final String targetDeviceName;
  final int _bufferSize = 7;
  final Duration _bufferTimeout = Duration(milliseconds: 105);
  List<double> _currentBuffer = [];
  Timer? _bufferTimer;

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
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            _valueSubscription = characteristic.onValueReceived.listen((value) {
              _handleIncomingData(value);
            });
            await characteristic.setNotifyValue(true);
            print("Подписался на уведомления: ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("Ошибка при поиске сервисов: $e");
    }
  }
  void _handleIncomingData(List<int> value) {
    final stringData = utf8.decode(value);
    final numbers = _parseStringToDoubleList(stringData);

    if (numbers.isEmpty) return;

    _currentBuffer.addAll(numbers);

    _bufferTimer?.cancel();
    _bufferTimer = Timer(_bufferTimeout, _flushBuffer);

    if (_currentBuffer.length >= _bufferSize) {
      _flushBuffer();
    }
  }

  void _flushBuffer() {
    if (_currentBuffer.isEmpty) return;

    final dataToSend = _currentBuffer.take(_bufferSize).toList();

    if (_currentBuffer.length > _bufferSize) {
      _currentBuffer = _currentBuffer.sublist(_bufferSize);
    } else {
      _currentBuffer.clear();
    }
    onNewData(dataToSend);
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