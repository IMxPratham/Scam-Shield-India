import '../core/detector.dart';
import 'text_rules.dart';

class TextDetector implements Detector {
  // Compile each regex once and keep it next to its rule.
  final List<MapEntry<TextRule, RegExp>> _compiled;

  TextDetector({List<TextRule> rules = textRules})
    : _compiled = [for (final r in rules) MapEntry(r, r.toRegExp())];

  @override
  String get name => 'Text analysis';

  @override
  List<Finding> analyze(String input) {
    final findings = <Finding>[];
    for (final entry in _compiled) {
      if (entry.value.hasMatch(input)) {
        findings.add(Finding(entry.key.reason, entry.key.points));
      }
    }
    return findings;
  }
}
