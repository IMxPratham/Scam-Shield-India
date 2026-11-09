import 'package:flutter/foundation.dart';

import '../core/detector.dart';
import '../data/scan_record.dart';
import '../data/scan_repository.dart';
import '../services/scan_service.dart';

class ScanProvider extends ChangeNotifier {
  final ScanService _service;
  final ScanRepository? _repository; // null in tests = nothing is saved

  ScanProvider(this._service, {this._repository});

  DetectionResult? _result;
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
    notifyListeners();
    _save(); // not awaited on purpose: the screen must not wait for the disk
  }

  Future<void> _save() async {
    final repo = _repository;
    final r = _result;
    if (repo == null || r == null || _lastInput.isEmpty) return;
    try {
      await repo.save(ScanRecord.fromResult(_lastInput, r));
    } catch (e) {
      debugPrint(
        'Could not save scan: $e',
      ); // a failed save must not crash a scan
    }
  }

  void clear() {
    _result = null;
    _lastInput = '';
    notifyListeners();
  }
}
