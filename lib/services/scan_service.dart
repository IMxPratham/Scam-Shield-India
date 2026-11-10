import '../core/detector.dart';
import 'package:flutter/foundation.dart';

/// The three possible outcomes. An enum stops typos like "High Risk" vs "High risk".
enum Verdict {
  likelySafe('Likely safe'),
  suspicious('Suspicious'),
  highRisk('High risk');

  final String label; // text shown to the user
  const Verdict(this.label);
}

class ScanService {
  static const int maxScore = 100;

  final List<Detector> detectors;

  ScanService(this.detectors);

  DetectionResult scan(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return DetectionResult(0, []);
    }

    // 1. Ask every detector for its findings.
    // 1. Ask every detector for its findings.
    final all = <Finding>[];
    var failed = 0;
    for (final detector in detectors) {
      try {
        all.addAll(detector.analyze(text));
      } catch (e) {
        // One broken detector must not stop the others.
        failed++;
        debugPrint('Detector ${detector.name} failed: $e');
      }
    }

    // 2. Biggest reasons first (b compared to a = descending order).
    all.sort((a, b) => b.points.compareTo(a.points));

    // 3. Add the points, then cap at 100.
    var total = 0;
    for (final finding in all) {
      total += finding.points;
    }
    if (total > maxScore) {
      total = maxScore;
    }

    return DetectionResult(total, all, failedChecks: failed);
  }

  /// static = belongs to the class, no ScanService object needed.
  static Verdict verdictFor(int score) {
    if (score >= 60) return Verdict.highRisk;
    if (score >= 30) return Verdict.suspicious;
    return Verdict.likelySafe;
  }
}
