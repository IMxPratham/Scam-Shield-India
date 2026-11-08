import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/services/domain_utils.dart';

void main() {
  group('extractHost', () {
    test('full https URL', () {
      expect(extractHost('https://www.sbi.co.in/login'), 'www.sbi.co.in');
    });

    test('bare link without scheme', () {
      expect(extractHost('sbi-kyc.xyz/login'), 'sbi-kyc.xyz');
    });

    test('uppercase is lowercased', () {
      expect(extractHost('HTTPS://SBI.CO.IN'), 'sbi.co.in');
    });

    test('port is removed', () {
      expect(extractHost('https://sbi.co.in:8443/x'), 'sbi.co.in');
    });

    test('bare link with port', () {
      expect(extractHost('hdfc.com:8080/x'), 'hdfc.com');
    });

    test('query string is ignored', () {
      expect(extractHost('http://a.com/p?next=b.com'), 'a.com');
    });

    test('whitespace is trimmed', () {
      expect(extractHost('  https://a.com  '), 'a.com');
    });

    test('IP address host', () {
      expect(extractHost('http://192.168.1.1/login'), '192.168.1.1');
    });

    test('@ trick: real host is after the @', () {
      expect(extractHost('http://sbi.co.in@evil.com/'), 'evil.com');
    });

    test('empty and blank input return null', () {
      expect(extractHost(''), isNull);
      expect(extractHost('   '), isNull);
    });

    test('scheme only returns null', () {
      expect(extractHost('http://'), isNull);
    });
  });
  group('isIpAddress', () {
    test('IPv4 is detected', () {
      expect(isIpAddress('192.168.1.1'), isTrue);
    });
    test('normal domain is not an IP', () {
      expect(isIpAddress('sbi.co.in'), isFalse);
    });
    test('IPv6 is detected', () {
      expect(isIpAddress('::1'), isTrue);
    });
  });

  group('registrableDomain', () {
    test('simple .com', () {
      expect(registrableDomain('www.hdfcbank.com'), 'hdfcbank.com');
    });
    test('co.in keeps three labels', () {
      expect(registrableDomain('www.sbi.co.in'), 'sbi.co.in');
    });
    test('trick: brand inside subdomain, real owner is evil.xyz', () {
      expect(registrableDomain('sbi.co.in.evil.xyz'), 'evil.xyz');
    });
    test('two labels returned as is', () {
      expect(registrableDomain('sbi-kyc.xyz'), 'sbi-kyc.xyz');
    });
    test('IP returned as is', () {
      expect(registrableDomain('192.168.1.1'), '192.168.1.1');
    });
  });

  group('subdomainCount', () {
    test('no subdomain', () {
      expect(subdomainCount('sbi.co.in'), 0);
    });
    test('one subdomain', () {
      expect(subdomainCount('www.sbi.co.in'), 1);
    });
    test('four subdomains', () {
      expect(subdomainCount('a.b.c.d.evil.xyz'), 4);
    });
    test('IP has none', () {
      expect(subdomainCount('192.168.1.1'), 0);
    });
  });

  group('parseLink', () {
    test('keeps the @ part so detectors can see it', () {
      expect(parseLink('http://sbi.co.in@evil.com/')?.userInfo, 'sbi.co.in');
    });
    test('empty input returns null', () {
      expect(parseLink(''), isNull);
    });
  });

  test('bank.in keeps three labels', () {
    expect(registrableDomain('retail.sbi.bank.in'), 'sbi.bank.in');
  });
}
