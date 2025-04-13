import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissions() async {
  PermissionStatus status = await Permission.bluetoothScan.request();
  if (status.isGranted) {
    print("Доступ получен");
  } else {
    print("Необходимо разрешение на сканирование Bluetooth");
  }
}
