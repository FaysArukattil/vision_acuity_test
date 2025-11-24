import 'eye_result.dart';

/// TestResult Model - Stores complete vision test results
/// Supports both near vision (both eyes) and distance vision (separate eyes) tests
class TestResult {
  final String testType; // 'near' or 'distance'
  final DateTime testDate; // When the test was performed
  final EyeResult? bothEyes; // For near vision test (both eyes open)
  final EyeResult? leftEye; // For distance vision test (left eye)
  final EyeResult? rightEye; // For distance vision test (right eye)

  TestResult({
    required this.testType,
    required this.testDate,
    this.bothEyes,
    this.leftEye,
    this.rightEye,
  });

  /// Validate that the test result has appropriate data
  bool get isValid {
    if (testType == 'near') {
      return bothEyes != null;
    } else if (testType == 'distance') {
      return leftEye != null && rightEye != null;
    }
    return false;
  }

  /// Get a summary description of the test results
  String get summary {
    if (testType == 'near' && bothEyes != null) {
      return 'Near Vision: ${bothEyes!.snellenFraction} (${bothEyes!.description})';
    } else if (testType == 'distance' && leftEye != null && rightEye != null) {
      return 'Distance Vision - Left: ${leftEye!.snellenFraction}, Right: ${rightEye!.snellenFraction}';
    }
    return 'Invalid test result';
  }

  /// Get average percentage for distance vision tests
  double? get averagePercentage {
    if (testType == 'distance' && leftEye != null && rightEye != null) {
      return (leftEye!.percentage + rightEye!.percentage) / 2;
    } else if (testType == 'near' && bothEyes != null) {
      return bothEyes!.percentage;
    }
    return null;
  }

  /// Get the worst result (lowest percentage) for distance tests
  EyeResult? get worstEye {
    if (testType == 'distance' && leftEye != null && rightEye != null) {
      return leftEye!.percentage < rightEye!.percentage ? leftEye : rightEye;
    }
    return null;
  }

  /// Get the best result (highest percentage) for distance tests
  EyeResult? get bestEye {
    if (testType == 'distance' && leftEye != null && rightEye != null) {
      return leftEye!.percentage > rightEye!.percentage ? leftEye : rightEye;
    }
    return null;
  }

  /// Check if there's significant difference between eyes (>20% difference)
  bool get hasSignificantDifference {
    if (testType == 'distance' && leftEye != null && rightEye != null) {
      final difference = (leftEye!.percentage - rightEye!.percentage).abs();
      return difference > 20.0;
    }
    return false;
  }

  /// Convert TestResult to JSON for storage/persistence
  Map<String, dynamic> toJson() {
    return {
      'testType': testType,
      'testDate': testDate.toIso8601String(),
      'bothEyes': bothEyes?.toJson(),
      'leftEye': leftEye?.toJson(),
      'rightEye': rightEye?.toJson(),
    };
  }

  /// Create TestResult from JSON
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testType: json['testType'] as String,
      testDate: DateTime.parse(json['testDate'] as String),
      bothEyes: json['bothEyes'] != null
          ? EyeResult.fromJson(json['bothEyes'] as Map<String, dynamic>)
          : null,
      leftEye: json['leftEye'] != null
          ? EyeResult.fromJson(json['leftEye'] as Map<String, dynamic>)
          : null,
      rightEye: json['rightEye'] != null
          ? EyeResult.fromJson(json['rightEye'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create a copy with optional field overrides
  TestResult copyWith({
    String? testType,
    DateTime? testDate,
    EyeResult? bothEyes,
    EyeResult? leftEye,
    EyeResult? rightEye,
  }) {
    return TestResult(
      testType: testType ?? this.testType,
      testDate: testDate ?? this.testDate,
      bothEyes: bothEyes ?? this.bothEyes,
      leftEye: leftEye ?? this.leftEye,
      rightEye: rightEye ?? this.rightEye,
    );
  }

  @override
  String toString() {
    return 'TestResult(testType: $testType, testDate: $testDate, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TestResult &&
        other.testType == testType &&
        other.testDate == testDate &&
        other.bothEyes == bothEyes &&
        other.leftEye == leftEye &&
        other.rightEye == rightEye;
  }

  @override
  int get hashCode {
    return testType.hashCode ^
        testDate.hashCode ^
        bothEyes.hashCode ^
        leftEye.hashCode ^
        rightEye.hashCode;
  }

  /// Format test date for display
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[testDate.month - 1]} ${testDate.day}, ${testDate.year}';
  }

  /// Format test time for display
  String get formattedTime {
    final hour = testDate.hour > 12 ? testDate.hour - 12 : testDate.hour;
    final period = testDate.hour >= 12 ? 'PM' : 'AM';
    final minute = testDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Get complete formatted date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  /// Get recommendation based on test results
  String get recommendation {
    final avgPercentage = averagePercentage;
    if (avgPercentage == null) {
      return 'Complete the test to get recommendations.';
    }

    if (avgPercentage >= 80.0) {
      return 'Your vision is good! Continue regular eye checkups to maintain your vision health.';
    } else if (avgPercentage >= 50.0) {
      return 'Your vision could be improved. Consider scheduling an appointment with an eye care professional for a comprehensive examination.';
    } else if (avgPercentage >= 30.0) {
      return 'We strongly recommend consulting an eye care professional soon for a thorough examination and possible corrective measures.';
    } else {
      return 'Please consult an eye care professional as soon as possible. Your vision may require immediate attention.';
    }
  }

  /// Get severity level (for color coding UI elements)
  String get severityLevel {
    final avgPercentage = averagePercentage;
    if (avgPercentage == null) return 'unknown';

    if (avgPercentage >= 80.0) return 'good';
    if (avgPercentage >= 50.0) return 'moderate';
    if (avgPercentage >= 30.0) return 'poor';
    return 'critical';
  }
}

/// Extension to add list operations for TestResult
extension TestResultList on List<TestResult> {
  /// Get all near vision tests
  List<TestResult> get nearTests {
    return where((test) => test.testType == 'near').toList();
  }

  /// Get all distance vision tests
  List<TestResult> get distanceTests {
    return where((test) => test.testType == 'distance').toList();
  }

  /// Sort by date (most recent first)
  List<TestResult> get sortedByDate {
    final sorted = List<TestResult>.from(this);
    sorted.sort((a, b) => b.testDate.compareTo(a.testDate));
    return sorted;
  }

  /// Get the most recent test
  TestResult? get mostRecent {
    if (isEmpty) return null;
    return sortedByDate.first;
  }

  /// Get tests from the last N days
  List<TestResult> testsInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return where((test) => test.testDate.isAfter(cutoffDate)).toList();
  }
}
