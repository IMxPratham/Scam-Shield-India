import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/core/detector.dart';
import 'package:scam_shield/data/scan_record.dart';

void main() {
  final result = DetectionResult(45, [Finding('Asks for OTP', 25)]);

  test('short input is kept as is', () {
    final r = ScanRecord.fromResult('hello', result);
    expect(r.inputPreview, 'hello');
  });

  test('long input is cut to 100 chars plus "..."', () {
    final r = ScanRecord.fromResult('a' * 500, result);
    expect(r.inputPreview.length, 103);
    expect(r.inputPreview.endsWith('...'), isTrue);
  });

  test('verdict comes from the score', () {
    expect(ScanRecord.fromResult('x', result).verdict, 'Suspicious');
  });

  test('toMap leaves out id when it is null', () {
    final map = ScanRecord.fromResult('x', result).toMap();
    expect(map.containsKey('id'), isFalse);
  });

  test('toMap then fromMap keeps the data', () {
    final original = ScanRecord.fromResult('hello', result);
    final copy = ScanRecord.fromMap(original.toMap());
    expect(copy.inputPreview, 'hello');
    expect(copy.score, 45);
    expect(copy.findings.first.reason, 'Asks for OTP');
    expect(copy.findings.first.points, 25);
  });
}
