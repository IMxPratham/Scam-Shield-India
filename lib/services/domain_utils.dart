Uri? parseLink(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;

  if (!text.contains('://')) {
    text = 'http://$text';
  }

  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  return uri; // <-- returns the whole Uri
}

String? extractHost(String input) {
  return parseLink(input)?.host.toLowerCase();
}

// Endings shared by many owners. The owner's name sits one label before.
const _multiPartSuffixes = {
  'co.in',
  'org.in',
  'gov.in',
  'nic.in',
  'net.in',
  'ac.in',
  'edu.in',
  'res.in',
  'firm.in',
  'gen.in',
  'ind.in',
  'bank.in',
  'fin.in',
};

final _ipv4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

bool isIpAddress(String host) {
  // Uri removes the [ ] around IPv6, so a ':' left in the host means IPv6.
  return _ipv4.hasMatch(host) || host.contains(':');
}

String registrableDomain(String host) {
  if (isIpAddress(host)) return host;

  final labels = host.split('.');
  if (labels.length <= 2) return host;

  final lastTwo = labels.sublist(labels.length - 2).join('.');
  if (_multiPartSuffixes.contains(lastTwo)) {
    return labels.sublist(labels.length - 3).join('.');
  }
  return lastTwo;
}

int subdomainCount(String host) {
  if (isIpAddress(host)) return 0;
  final totalLabels = host.split('.').length;
  final ownLabels = registrableDomain(host).split('.').length;
  return totalLabels - ownLabels;
}
