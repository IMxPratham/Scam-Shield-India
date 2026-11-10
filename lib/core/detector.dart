/// One reason why the input looks risky, and how many points it adds.
class Finding {
  final String reason;
  final int points;

  const Finding(this.reason, this.points);
}

/// The final answer: total score (0-100) and the list of reasons.
/// The final answer: total score (0-100), the list of reasons,
/// and how many detectors crashed while checking.
class DetectionResult {
  final int score;
  final List<Finding> findings;
  final int failedChecks;

  const DetectionResult(this.score, this.findings, {this.failedChecks = 0});
}

/// Every analyzer (text, URL, and future ones) must follow this contract.
abstract class Detector {
  String get name;
  List<Finding> analyze(String input);
}
