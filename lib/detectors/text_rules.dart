class TextRule {
  final String reason;
  final int points;
  final List<String> keywords;
  final String? pattern; // optional: a ready-made regex string
  final List<String> safeIfContains;

  const TextRule(
    this.reason,
    this.points,
    this.keywords, {
    this.pattern,
    this.safeIfContains = const [],
  });

  RegExp toRegExp() {
    if (pattern != null) return RegExp(pattern!, caseSensitive: false);
    final escaped = keywords.map(RegExp.escape).join('|');
    return RegExp('\\b($escaped)\\b', caseSensitive: false);
  }

  RegExp? toSafeRegExp() {
    if (safeIfContains.isEmpty) return null;
    final escaped = safeIfContains.map(RegExp.escape).join('|');
    return RegExp('\\b($escaped)\\b', caseSensitive: false);
  }
}

const List<TextRule> textRules = [
  TextRule(
    'Asks for OTP, PIN, CVV or password',
    25,
    [
      'your otp',
      'send otp',
      'share otp',
      'enter otp',
      'your pin',
      'atm pin',
      'upi pin',
      'share pin',
      'cvv',
      'your password',
    ],
    safeIfContains: [
      'do not share',
      'never share',
      "don't share",
      "don’t share",
    ],
  ),
  TextRule('Creates urgency or threatens you', 15, [
    'urgent',
    'immediately',
    'blocked',
    'suspended',
    'will expire',
    'expires today',
    'has expired',
    'is expired',
  ]),
  TextRule('Claims a prize, lottery or cashback', 20, [
    'you have won',
    'lottery',
    'lucky draw',
    'cashback',
    'claim your prize',
  ]),
  TextRule('KYC or account verification request', 20, [
    'verify your account',
    'account verification',
    'update kyc',
    'identity verification',
    'kyc pending',
    'kyc expired',
    'pan card update',
  ]),
  TextRule(
    'UPI collect / money request',
    20,
    [],
    pattern:
        r'(?<!\bi will )(?<!\bi’ll )(?<!\bi\x27ll )\b(pay|send|transfer)\s+(rs\.?|₹|inr)?\s*\d+'
        r'|collect request|accept the request',
  ),
  TextRule('Legal / arrest threat', 20, [
    'arrest warrant',
    'legal action',
    'case filed',
    'court notice',
  ]),
  TextRule('Asks you to call a number', 10, [
    'call this number',
    'call us immediately',
    'contact on',
  ]),
  TextRule('Contains a link', 5, [], pattern: r'https?://|www\.'),
];
