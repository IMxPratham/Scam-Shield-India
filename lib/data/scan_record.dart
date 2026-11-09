import 'dart:convert';

import '../core/detector.dart';
import '../services/scan_service.dart';

/// One saved scan. It stores only a short preview of the text, never the full message.
class ScanRecord {
  static const int previewLength = 100;

  final int? id; // null until the database assigns one
  final String inputPreview;
  final int score;
  final String verdict;
  final String reasonsJson;
  final DateTime createdAt;

  const ScanRecord({
    this.id,
    required this.inputPreview,
    required this.score,
    required this.verdict,
    required this.reasonsJson,
    required this.createdAt,
  });

  /// Build a record from a fresh scan.
  factory ScanRecord.fromResult(
    String input,
    DetectionResult result, {
    DateTime? now,
  }) {
    final text = input.trim();
    final preview = text.length > previewLength
        ? '${text.substring(0, previewLength)}...'
        : text;

    final reasons = result.findings
        .map((f) => {'reason': f.reason, 'points': f.points})
        .toList();

    return ScanRecord(
      inputPreview: preview,
      score: result.score,
      verdict: ScanService.verdictFor(result.score).label,
      reasonsJson: jsonEncode(reasons),
      createdAt: now ?? DateTime.now(),
    );
  }

  /// Record -> a Map that matches the table columns.
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id, // leave id out so AUTOINCREMENT assigns it
    'input_preview': inputPreview,
    'score': score,
    'verdict': verdict,
    'reasons_json': reasonsJson,
    'created_at': createdAt.toIso8601String(),
  };

  /// A database row -> record.
  factory ScanRecord.fromMap(Map<String, Object?> map) => ScanRecord(
    id: map['id'] as int?,
    inputPreview: map['input_preview'] as String,
    score: map['score'] as int,
    verdict: map['verdict'] as String,
    reasonsJson: map['reasons_json'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  /// Decode the stored JSON back into Finding objects.
  List<Finding> get findings {
    final list = jsonDecode(reasonsJson) as List<dynamic>;
    return list
        .map((e) => Finding(e['reason'] as String, e['points'] as int))
        .toList();
  }
}
