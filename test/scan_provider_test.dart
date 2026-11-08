import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/detectors/text_detector.dart';
import 'package:scam_shield/detectors/url_detector.dart';
import 'package:scam_shield/providers/scan_provider.dart';
import 'package:scam_shield/services/scan_service.dart';

void main() {
  ScanProvider makeProvider() =>
      ScanProvider(ScanService([TextDetector(), UrlDetector()]));

  test('starts with no result and no verdict', () {
    final p = makeProvider();
    expect(p.result, isNull);
    expect(p.verdict, isNull);
  });

  test('scan stores result and notifies listeners once', () {
    final p = makeProvider();
    var calls = 0;
    p.addListener(() => calls++);

    p.scan('Share your OTP now');

    expect(p.result, isNotNull);
    expect(p.result!.score, greaterThan(0));
    expect(p.verdict, isNotNull);
    expect(calls, 1);
  });

  test('scan trims the stored input', () {
    final p = makeProvider();
    p.scan('   hello   ');
    expect(p.lastInput, 'hello');
  });

  test('clear resets state and notifies', () {
    final p = makeProvider();
    p.scan('Share your OTP now');
    var calls = 0;
    p.addListener(() => calls++);

    p.clear();

    expect(p.result, isNull);
    expect(p.lastInput, '');
    expect(calls, 1);
  });
}
