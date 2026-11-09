import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/scan_repository.dart';
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
    return MultiProvider(
      providers: [
        Provider<ScanRepository>(create: (_) => ScanRepository(AppDatabase())),
        ChangeNotifierProvider<ScanProvider>(
          create: (ctx) => ScanProvider(
            ScanService([TextDetector(), UrlDetector()]),
            repository: ctx.read<ScanRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ScamShield India',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
