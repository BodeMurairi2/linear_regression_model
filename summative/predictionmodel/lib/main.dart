import 'package:flutter/material.dart';

import 'screens/prediction_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MalariaEstimaterApp());
}

class MalariaEstimaterApp extends StatelessWidget {
  const MalariaEstimaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malaria Prevalence Estimater',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const PredictionScreen(),
    );
  }
}
