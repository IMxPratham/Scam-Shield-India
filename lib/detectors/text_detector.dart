import '../core/detector.dart';
import 'text_rules.dart';

/// Holds one rule together with its two ready-made regexes.
class _CompiledRule {
  final TextRule rule;
  final RegExp regex;
  final RegExp? safeRegex;

  _CompiledRule(this.rule, this.regex, this.safeRegex);
}

class TextDetector implements Detector {
  final List<_CompiledRule> _compiled;

  TextDetector({List<TextRule> rules = textRules})
    : _compiled = [
        for (final r in rules) _CompiledRule(r, r.toRegExp(), r.toSafeRegExp()),
      ];

  @override
  String get name => 'Text analysis';

  @override
  List<Finding> analyze(String input) {
    final findings = <Finding>[];
    for (final c in _compiled) {
      final looksScammy = c.regex.hasMatch(input);
      final isCancelled = c.safeRegex != null && c.safeRegex!.hasMatch(input);
      if (looksScammy && !isCancelled) {
        findings.add(Finding(c.rule.reason, c.rule.points));
      }
    }
    return findings;
  }
}
