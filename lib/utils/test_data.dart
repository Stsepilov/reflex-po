import 'dart:async';
import 'dart:math';

typedef OnNewDataCallback = void Function(List<double> newValues);

Future<void> start(OnNewDataCallback callback) async{
  while (true) {
    await Future.delayed(const Duration(seconds: 1), () {
      List<double> values = [];
      double value = 0;
      for (int i = 0; i < 100; i++) {
        if (i % 50 == 0) {
          value = 3000 + Random().nextDouble() * 500;
        } else {
          value = 1000 + Random().nextDouble() * 100;
        }
        values.add(value);
      }
      callback(values);
    });
  }
}

