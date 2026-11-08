/// A brand that scammers like to imitate.
class Brand {
  const Brand({
    required this.name,
    required this.keywords,
    required this.domains,
  });

  final String name;
  final List<String> keywords; // single words, lowercase
  final List<String> domains; // official registrable domains only
}

// STATUS: only SBI was researched, and only through secondary sources.
// Every domain below must be opened in a browser by YOU before you
// claim it as "verified" (see the checklist in the chat).
const brands = [
  Brand(
    name: 'State Bank of India',
    keywords: ['sbi', 'onlinesbi'],
    domains: ['sbi.co.in', 'bank.sbi', 'onlinesbi.sbi', 'sbi.bank.in'],
  ),
  Brand(
    name: 'HDFC Bank',
    keywords: ['hdfc', 'hdfcbank'],
    domains: ['hdfcbank.com'],
  ),
  Brand(
    name: 'ICICI Bank',
    keywords: ['icici', 'icicibank'],
    domains: ['icicibank.com'],
  ),
  Brand(
    name: 'Axis Bank',
    keywords: ['axisbank'], // "axis" alone is a normal English word
    domains: ['axisbank.com'],
  ),
  Brand(name: 'Paytm', keywords: ['paytm'], domains: ['paytm.com']),
];

// All official domains in one Set, for fast "is this the real site?" checks.
final officialDomains = {for (final brand in brands) ...brand.domains};

const shortenerDomains = {
  'bit.ly',
  'tinyurl.com',
  't.co',
  'goo.gl',
  'is.gd',
  'cutt.ly',
  'rb.gy',
  'ow.ly',
  'shorturl.at',
  'tiny.cc',
};

const suspiciousTlds = ['xyz', 'top', 'click', 'icu'];

// A word like "Dear.Customer" looks like a domain, so for links WITHOUT
// http:// or www. we only accept these endings.
const bareLinkTlds = {
  'com',
  'in',
  'net',
  'org',
  'co',
  'xyz',
  'top',
  'click',
  'icu',
  'info',
  'online',
  'site',
  'live',
  'app',
  'link',
  'bank',
  'sbi',
};
