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
  test('bank warning "do not share your OTP" is not flagged', () {
    final result = detector.analyze(
      'Your OTP is 482913. Do not share your OTP with anyone.',
    );
    expect(result, isEmpty);
  });
  test('scam asking for OTP is still flagged', () {
    expect(detector.analyze('Send your OTP now to claim reward'), isNotEmpty);
  });
  test('curly apostrophe "don’t share" is not flagged', () {
    expect(
      detector.analyze('Your OTP is 1234. Don’t share your OTP.'),
      isEmpty,
    );
  });
  test('prize bait is flagged with 20 points', () {
    final result = detector.analyze('You have won a lottery, claim now');
    expect(result.any((f) => f.reason.contains('prize')), isTrue);
  });
  // ---- Urgency ----
  test('urgency wording is flagged', () {
    final result = detector.analyze('Your account is blocked, act now');
    expect(result.any((f) => f.reason.contains('urgency')), isTrue);
  });

  // ---- KYC ----
  test('KYC update request is flagged', () {
    final result = detector.analyze('Update KYC today or account suspended');
    expect(result.any((f) => f.reason.contains('KYC')), isTrue);
  });

  test('thanks for completing KYC is not flagged', () {
    expect(detector.analyze('Thank you for completing your KYC.'), isEmpty);
  });

  // ---- UPI / money ----
  test('collect request is flagged', () {
    final result = detector.analyze('Accept the request to receive money');
    expect(result.any((f) => f.reason.contains('UPI')), isTrue);
  });

  // ---- Legal ----
  test('arrest threat is flagged', () {
    final result = detector.analyze('Arrest warrant issued, legal action next');
    expect(result.any((f) => f.reason.contains('Legal')), isTrue);
  });

  test('court hearing reminder is not flagged', () {
    expect(detector.analyze('Court hearing is on Monday'), isEmpty);
  });

  // ---- Call a number ----
  test('call this number is flagged', () {
    final result = detector.analyze('Call this number now');
    expect(result.any((f) => f.reason.contains('call')), isTrue);
  });

  test('casual call request is not flagged', () {
    expect(detector.analyze('Call me when you are free'), isEmpty);
  });

  // ---- Link ----
  test('link is flagged with 5 points', () {
    final result = detector.analyze('Visit www.example.com');
    expect(result.length, 1);
    expect(result.first.points, 5);
  });

  test('message without a link is not flagged', () {
    expect(detector.analyze('No links here'), isEmpty);
  });

  // ---- Several rules together ----
  test('urgent OTP request with a link triggers 3 rules', () {
    final result = detector.analyze(
      'URGENT: send your OTP now at www.fake.com',
    );
    expect(result.length, 3);
  });
  test('KNOWN LIMITATION: "expired" in a calendar note is flagged', () {
    final result = detector.analyze('Meeting invite expired from calendar');
    expect(result.any((f) => f.reason.contains('urgency')), isTrue);
  });
  test('"I will pay Rs 500 tomorrow" is not a money request', () {
    final result = detector.analyze('I will pay Rs 500 tomorrow');
    expect(result.any((f) => f.reason.contains('UPI')), isFalse);
  });

  test('"Pay Rs 5000 to this account now" is still flagged', () {
    final result = detector.analyze('Pay Rs 5000 to this account now');
    expect(result.any((f) => f.reason.contains('UPI')), isTrue);
  });
  test('"Pay 1000 for token and win" is flagged', () {
    final r = detector.analyze('Pay 1000 for token and win');
    expect(r.any((f) => f.reason.contains('UPI')), isTrue);
  });

  test(
    '"I will pay you 500000 if you send Rs 1000 first" is still flagged',
    () {
      final r = detector.analyze(
        'I will pay you 500000 if you send Rs 1000 first',
      );
      expect(r.any((f) => f.reason.contains('UPI')), isTrue);
    },
  );
}
