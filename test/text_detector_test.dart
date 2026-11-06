import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/detectors/text_detector.dart';

void main() {
  final detector = TextDetector();

  test('empty string gives no findings', () {
    expect(detector.analyze(''), isEmpty);
  });

  test('normal friendly message gives no findings', () {
    expect(detector.analyze('Hi, are we meeting at 5 pm today?'), isEmpty);
  });

  test('asking for UPI PIN is flagged with 25 points', () {
    final result = detector.analyze('Please share pin to continue');
    expect(result.length, 1);
    expect(result.first.points, 25);
  });

  test('matching is case-insensitive', () {
    expect(detector.analyze('URGENT: act now'), isNotEmpty);
  });

  test('PIN code in an address is not flagged', () {
    expect(detector.analyze('Delivery to PIN code 400001'), isEmpty);
  });
}
