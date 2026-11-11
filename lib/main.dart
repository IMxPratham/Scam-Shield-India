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
        debugShowCheckedModeBanner: false,
        title: 'ScamShield India',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
          // Flat cards with a soft border and rounded corners.
          cardTheme: CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
