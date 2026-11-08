import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'detectors/text_detector.dart';
import 'detectors/url_detector.dart';
import 'providers/scan_provider.dart';
import 'services/scan_service.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const ScamShieldApp());
}

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // The detector list is built here, in one place.
      create: (_) => ScanProvider(ScanService([TextDetector(), UrlDetector()])),
      child: MaterialApp(
        title: 'ScamShield India',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
