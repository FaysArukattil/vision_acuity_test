import 'package:flutter/material.dart';
import '../utils/vision_calculator.dart';

/// EyeResult Model - Stores results for a single eye or both eyes
class EyeResult {
  final String snellenFraction; // e.g., '6/6', '6/12', '6/60'
  final DateTime testDate; // When the test was performed

  EyeResult({
    required this.snellenFraction,
    required this.testDate,
  });

  /// Calculate visual acuity as percentage (6/6 = 100%)
  double get percentage {
    return VisionCalculator.calculateAcuityPercentage(snellenFraction);
  }

  /// Get description: 'Excellent', 'Good', 'Moderate', 'Poor', 'Very Poor'
  String get description {
    return VisionCalculator.getAcuityDescription(snellenFraction);
  }

  /// Get color for UI display
  Color get color {
    return VisionCalculator.getAcuityColor(snellenFraction);
  }

  /// Convert EyeResult to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'snellenFraction': snellenFraction,
      'testDate': testDate.toIso8601String(),
    };
  }

  /// Create EyeResult from JSON
  factory EyeResult.fromJson(Map<String, dynamic> json) {
    return EyeResult(
      snellenFraction: json['snellenFraction'] as String,
      testDate: DateTime.parse(json['testDate'] as String),
    );
  }

  /// Create a copy with optional field overrides
  EyeResult copyWith({
    String? snellenFraction,
    DateTime? testDate,
  }) {
    return EyeResult(
      snellenFraction: snellenFraction ?? this.snellenFraction,
      testDate: testDate ?? this.testDate,
    );
  }

  @override
  String toString() {
    return 'EyeResult(snellenFraction: $snellenFraction, percentage: ${percentage.toStringAsFixed(1)}%, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EyeResult &&
        other.snellenFraction == snellenFraction &&
        other.testDate == testDate;
  }

  @override
  int get hashCode {
    return snellenFraction.hashCode ^ testDate.hashCode;
  }
}
