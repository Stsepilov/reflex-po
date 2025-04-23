import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import '../themes/theme_extensions.dart';
import '../widgets/chart_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context)
        .extension<AppThemeExtension>()!
        .backgroundGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: PulseChart()
        )
    );
  }
}