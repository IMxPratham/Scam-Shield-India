/// One scam-wording rule: if any pattern matches, add [points] once.
class TextRule {
  final String reason;
  final int points;
  final List<String> keywords;

  const TextRule(this.reason, this.points, this.keywords);

  /// Builds one regex like: \b(otp|pin|cvv)\b  (case-insensitive)
  RegExp toRegExp() {
    final escaped = keywords.map(RegExp.escape).join('|');
    return RegExp('\\b($escaped)\\b', caseSensitive: false);
  }
}

const List<TextRule> textRules = [
  TextRule(
    'Asks for OTP, PIN, CVV or password',
    25,
    ['otp', 'pin', 'cvv', 'password'],
  ),
  TextRule(
    'Creates urgency or threatens you',
    15,
    ['urgent', 'immediately', 'blocked', 'suspended', 'expire'],
  ),
];