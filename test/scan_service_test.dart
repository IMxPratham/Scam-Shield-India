import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/core/detector.dart';
import 'package:scam_shield/detectors/text_detector.dart';
import 'package:scam_shield/detectors/url_detector.dart';
import 'package:scam_shield/services/scan_service.dart';

/// A fake detector that always returns the findings we give it.
/// This lets us test ScanService without depending on real rules.
class FakeDetector implements Detector {
  final List<Finding> findings;
  FakeDetector(this.findings);

  @override
  String get name => 'fake';

  @override
  List<Finding> analyze(String input) => findings;
}

/// A detector that always crashes. Used to test that one bad detector
/// does not break the whole scan.
class ThrowingDetector implements Detector {
  @override
  String get name => 'throwing';

  @override
  List<Finding> analyze(String input) => throw StateError('boom');
}

void main() {
  group('ScanService.scan', () {
    test('empty input gives score 0 and no findings', () {
      final service = ScanService([
        FakeDetector([Finding('x', 50)]),
      ]);
      final result = service.scan('');
      expect(result.score, 0);
      expect(result.findings, isEmpty);
    });

    test('whitespace-only input is treated as empty', () {
      final service = ScanService([
        FakeDetector([Finding('x', 50)]),
      ]);
      expect(service.scan('   \n  ').score, 0);
    });

    test('adds points from all detectors', () {
      final service = ScanService([
        FakeDetector([Finding('a', 10)]),
        FakeDetector([Finding('b', 15), Finding('c', 5)]),
      ]);
      final result = service.scan('hello');
      expect(result.score, 30);
      expect(result.findings.length, 3);
    });

    test('caps the score at 100', () {
      final service = ScanService([
        FakeDetector([Finding('a', 70), Finding('b', 60)]),
      ]);
      expect(service.scan('hello').score, 100);
    });

    test('sorts findings by points, highest first', () {
      final service = ScanService([
        FakeDetector([
          Finding('small', 5),
          Finding('big', 25),
          Finding('mid', 15),
        ]),
      ]);
      final points = service
          .scan('hello')
          .findings
          .map((f) => f.points)
          .toList();
      expect(points, [25, 15, 5]);
    });

    test('works with no detectors', () {
      expect(ScanService([]).scan('hello').score, 0);
    });
  });

  test('one detector throwing does not stop the others', () {
    final service = ScanService([
      ThrowingDetector(),
      FakeDetector([Finding('a', 10)]),
    ]);
    final result = service.scan('hello');
    expect(result.score, 10);
    expect(result.findings.length, 1);
  });
  test('failedChecks counts detectors that threw', () {
    final service = ScanService([
      ThrowingDetector(),
      FakeDetector([Finding('a', 10)]),
    ]);
    expect(service.scan('hello').failedChecks, 1);
  });

  test('failedChecks is 0 when every detector works', () {
    final service = ScanService([
      FakeDetector([Finding('a', 10)]),
    ]);
    expect(service.scan('hello').failedChecks, 0);
  });
  group('ScanService.verdictFor boundaries', () {
    test('0 and 29 are likely safe', () {
      expect(ScanService.verdictFor(0), Verdict.likelySafe);
      expect(ScanService.verdictFor(29), Verdict.likelySafe);
    });

    test('30 and 59 are suspicious', () {
      expect(ScanService.verdictFor(30), Verdict.suspicious);
      expect(ScanService.verdictFor(59), Verdict.suspicious);
    });

    test('60 and 100 are high risk', () {
      expect(ScanService.verdictFor(60), Verdict.highRisk);
      expect(ScanService.verdictFor(100), Verdict.highRisk);
    });
  });

  group('ScanService with real detectors', () {
    final service = ScanService([TextDetector(), UrlDetector()]);

    test('fake scam message is high risk', () {
      final result = service.scan(
        'URGENT: your SBI KYC will expire today. '
        'Share OTP at http://sbi-kyc-update.xyz',
      );
      expect(result.score, greaterThanOrEqualTo(60));
      expect(ScanService.verdictFor(result.score), Verdict.highRisk);
    });

    test('harmless message is likely safe', () {
      final result = service.scan('Lunch at 1pm tomorrow?');
      expect(result.score, lessThan(30));
    });

    test('KNOWN LIMITATION: friendly hook message scores 0', () {
      final r = service.scan(
        'Hey, are we still meeting for golf tomorrow at 10?',
      );
      expect(r.score, 0);
    });

    test('KNOWN LIMITATION: executive-fraud style message scores 0', () {
      final r = service.scan(
        'Hi, are you at your desk? I need you to handle a quick vendor '
        'payment before the wire cutoff.',
      );
      expect(r.score, 0);
    });
  });
}
