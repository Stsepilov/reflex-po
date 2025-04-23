import 'package:flutter/material.dart';
import 'package:reflex/screens/main_screen.dart';
import 'package:reflex/themes/app_theme.dart';

void main() {
  runApp(const ReFlex());
}

class ReFlex extends StatelessWidget {
  const ReFlex({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: HomePage(),
    );
  }
}
