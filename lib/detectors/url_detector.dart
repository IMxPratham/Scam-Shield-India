import 'package:scam_shield/core/detector.dart';
import 'package:scam_shield/services/domain_utils.dart';
import 'package:scam_shield/services/levenshtein.dart';
import 'package:scam_shield/detectors/url_rules.dart';

class UrlDetector implements Detector {
  @override
  String get name => 'URL detector';

  @override
  List<Finding> analyze(String input) {
    var worst = <Finding>[];
    var worstScore = 0;

    for (final link in _extractLinks(input)) {
      final findings = _analyzeLink(link);
      final total = findings.fold<int>(0, (sum, f) => sum + f.points);
      if (total > worstScore) {
        worst = findings;
        worstScore = total;
      }
    }
    return worst;
  }
}

// ---------- 1. find links inside a message ----------

// Removes ( " ' < at the start and . , ; : ! ? ) " ' > at the end.
final _edgePunctuation = RegExp(r'''^[("'<]+|[.,;:!?)"'>]+$''');
final _bareLink = RegExp(r'^[a-z0-9-]+(\.[a-z0-9-]+)*\.[a-z]{2,}([:/?#].*)?$');

List<String> _extractLinks(String input) {
  final links = <String>[];
  for (final word in input.split(RegExp(r'\s+'))) {
    final token = word.replaceAll(_edgePunctuation, '');
    if (token.isNotEmpty && _looksLikeLink(token)) links.add(token);
  }
  return links;
}

bool _looksLikeLink(String token) {
  final lower = token.toLowerCase();
  if (lower.contains('://') || lower.startsWith('www.')) return true;
  if (!_bareLink.hasMatch(lower)) return false;
  final host = lower.split(RegExp(r'[/?#:]')).first;
  return bareLinkTlds.contains(host.split('.').last);
}

// ---------- 2. apply the rules to one link ----------

List<Finding> _analyzeLink(String link) {
  final uri = parseLink(link);
  final host = extractHost(link);
  if (uri == null || host == null) return [];

  final findings = <Finding>[];
  final owner = registrableDomain(host);

  // Structural rules
  if (isIpAddress(host)) {
    findings.add(
      Finding('Link uses an IP address instead of a website name', 25),
    );
  }
  if (host.contains('xn--')) {
    findings.add(
      Finding(
        'Link contains punycode (xn--), which can hide look-alike letters',
        25,
      ),
    );
  }
  if (uri.userInfo.isNotEmpty) {
    findings.add(
      Finding('Link has an @ symbol; the real site is the part after it', 20),
    );
  }
  if (shortenerDomains.contains(owner)) {
    findings.add(Finding('Shortened link hides the real destination', 15));
  }
  final tld = host.split('.').last;
  if (suspiciousTlds.contains(tld)) {
    findings.add(Finding('Link has a suspicious domain ending (.$tld)', 15));
  }
  if ('-'.allMatches(owner).length >= 2) {
    findings.add(Finding('Domain has 2 or more hyphens', 10));
  }
  if (subdomainCount(host) > 3) {
    findings.add(Finding('Link has more than 3 subdomains', 10));
  }
  // Use the ORIGINAL text: parseLink adds "http://" to bare links.
  if (link.toLowerCase().startsWith('http://')) {
    findings.add(Finding('Link does not use HTTPS', 10));
  }
  if (link.length > 75) {
    findings.add(Finding('Link is very long', 5));
  }

  // Brand rules: skipped when the owner IS an official brand domain.
  if (!officialDomains.contains(owner)) {
    final fake = _lookalikeOf(owner);
    if (fake != null) {
      findings.add(Finding('Looks like a fake copy of $fake', 35));
    }
    final brand = _brandInLink(host, uri.path);
    if (brand != null) {
      findings.add(
        Finding(
          'Uses the name "${brand.name}" but the real site is $owner',
          30,
        ),
      );
    }
  }
  return findings;
}

String? _lookalikeOf(String owner) {
  for (final official in officialDomains) {
    final distance = levenshtein(owner, official);
    if (distance >= 1 && distance <= 2) return official;
  }
  return null;
}

Brand? _brandInLink(String host, String path) {
  // Split on anything that is not a letter or digit: "sbi-kyc.xyz" -> sbi, kyc, xyz
  final tokens = '$host ${path.toLowerCase()}'.split(RegExp(r'[^a-z0-9]+'));
  for (final brand in brands) {
    if (brand.keywords.any(tokens.contains)) return brand;
  }
  return null;
}
