import 'package:flutter/foundation.dart';

import '../core/detector.dart';
import '../services/scan_service.dart';

class ScanProvider extends ChangeNotifier {
  final ScanService _service;

  ScanProvider(this._service);

  DetectionResult? _result; // null = nothing scanned yet
  String _lastInput = '';

  DetectionResult? get result => _result;
  String get lastInput => _lastInput;

  Verdict? get verdict {
    final r = _result;
    if (r == null) return null;
    return ScanService.verdictFor(r.score);
  }

  void scan(String input) {
    _lastInput = input.trim();
    _result = _service.scan(_lastInput);
    notifyListeners(); // tell the UI "something changed, redraw"
  }

  void clear() {
    _result = null;
    _lastInput = '';
    notifyListeners();
  }
}
