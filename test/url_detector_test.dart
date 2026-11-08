import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/detectors/url_detector.dart';

void main() {
  final detector = UrlDetector();

  int score(String text) =>
      detector.analyze(text).fold<int>(0, (sum, f) => sum + f.points);

  bool flags(String text, String word) =>
      detector.analyze(text).any((f) => f.reason.contains(word));

  group('no link / safe', () {
    test('empty input', () {
      expect(detector.analyze(''), isEmpty);
    });
    test('plain text has no link', () {
      expect(detector.analyze('Hello, meet me at 5 pm'), isEmpty);
    });
    test('Dear.Customer is not treated as a link', () {
      expect(detector.analyze('Dear.Customer please update'), isEmpty);
    });
    test('official https site scores 0', () {
      expect(score('https://www.sbi.co.in/login'), 0);
    });
    test('official bare link scores 0', () {
      expect(score('www.sbi.co.in'), 0);
    });
    test('official subdomain scores 0', () {
      expect(score('https://netbanking.hdfcbank.com/login'), 0);
    });
    test('ordinary bare link scores 0', () {
      expect(score('example.com'), 0);
    });
  });

  group('structural rules', () {
    test('IP address +25', () {
      expect(score('https://192.168.1.1/login'), 25);
    });
    test('punycode is flagged', () {
      expect(flags('https://xn--pypal-4ve.com', 'punycode'), isTrue);
    });
    test('@ symbol +20', () {
      expect(score('https://sbi.co.in@evil.com/x'), 20);
    });
    test('shortened link +15', () {
      expect(score('https://bit.ly/abc123'), 15);
    });
    test('suspicious TLD +15', () {
      expect(score('https://random-shop.xyz'), 15);
    });
    test('http without s +10', () {
      expect(score('http://example.com'), 10);
    });
    test('2 hyphens +10', () {
      expect(score('https://a-b-c.com'), 10);
    });
    test('more than 3 subdomains +10', () {
      expect(score('https://a.b.c.d.example.com'), 10);
    });
    test('very long link +5', () {
      expect(score('https://example.com/${'a' * 60}'), 5);
    });
  });

  group('brand rules', () {
    test('lookalike sbl.co.in +35', () {
      expect(score('https://sbl.co.in/login'), 35);
    });
    test('lookalike hdfcbamk.com +35', () {
      expect(score('https://hdfcbamk.com'), 35);
    });
    test('brand in subdomain: +30 and +15 for .xyz', () {
      expect(score('https://sbi.co.in.evil.xyz/login'), 45);
    });
    test('brand in path +30', () {
      expect(score('https://evil.com/hdfcbank/login'), 30);
    });
    test('bare sbi-kyc.xyz scores 45', () {
      expect(score('sbi-kyc.xyz'), 45);
    });
  });

  group('messages with links', () {
    test('worst link wins, scores are not added', () {
      expect(score('Visit https://bit.ly/x or http://192.168.1.1/a'), 35);
    });
    test('trailing full stop is ignored', () {
      expect(score('Click https://bit.ly/abc.'), 15);
    });
  });
}
