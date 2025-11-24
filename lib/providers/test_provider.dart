import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../model/eye_result.dart';
import '../model/test_result.dart';

/// Test Provider
/// Manages the state and logic for vision tests
class TestProvider with ChangeNotifier {
  // Test configuration
  String _testType = 'near'; // 'near' or 'distance'
  String _currentEye = 'both'; // 'both', 'left', or 'right'
  double _distanceMm = VisionConstants.nearDistanceMm;
  double _pixelsPerMm = 1.0;

  // Test state
  int _currentLevelIndex = 0;
  int _currentDirection = 0;
  int _totalAtLevel = 0;
  int _correctAtLevel = 0;
  int _consecutiveWrong = 0;
  bool _isTestComplete = false;
  String? _currentResult;

  // Results storage
  EyeResult? _leftEyeResult;
  EyeResult? _rightEyeResult;
  EyeResult? _bothEyesResult;

  // Getters
  String get testType => _testType;
  String get currentEye => _currentEye;
  double get distanceMm => _distanceMm;
  int get currentLevelIndex => _currentLevelIndex;
  String get currentLevel => VisionConstants.snellenLevels[_currentLevelIndex];
  int get currentDirection => _currentDirection;
  bool get isTestComplete => _isTestComplete;
  String? get currentResult => _currentResult;
  int get totalAtLevel => _totalAtLevel;
  int get correctAtLevel => _correctAtLevel;
  EyeResult? get leftEyeResult => _leftEyeResult;
  EyeResult? get rightEyeResult => _rightEyeResult;
  EyeResult? get bothEyesResult => _bothEyesResult;

  /// Initialize test
  void initializeTest({
    required String testType,
    required double distanceMm,
    required double pixelsPerMm,
    String eye = 'both',
  }) {
    _testType = testType;
    _currentEye = eye;
    _distanceMm = distanceMm;
    // Use provided pixelsPerMm if valid (calibrated), otherwise use default
    _pixelsPerMm = pixelsPerMm > 1.0 ? pixelsPerMm : VisionConstants.defaultPixelsPerMm;
    _currentLevelIndex = 0;
    _totalAtLevel = 0;
    _correctAtLevel = 0;
    _consecutiveWrong = 0;
    _isTestComplete = false;
    _currentResult = null;
    
    _generateNewDirection();
    notifyListeners();
  }

  /// Generate random direction for Tumbling E
  void _generateNewDirection() {
    final random = Random();
    _currentDirection = random.nextInt(4); // 0, 1, 2, or 3
  }

  /// Handle swipe gesture
  void handleSwipe(int swipedDirection) {
    if (_isTestComplete) return;

    final correct = swipedDirection == _currentDirection;

    _totalAtLevel++;
    if (correct) {
      _correctAtLevel++;
      _consecutiveWrong = 0;
    } else {
      _consecutiveWrong++;
    }

    // Check if we should move to next level or end test
    if (_totalAtLevel >= VisionConstants.trialsPerLevel) {
      // Completed all trials for this level
      if (_correctAtLevel >= VisionConstants.passThreshold) {
        // Passed this level, move to next
        if (_currentLevelIndex < VisionConstants.snellenLevels.length - 1) {
          _currentLevelIndex++;
          _totalAtLevel = 0;
          _correctAtLevel = 0;
          _consecutiveWrong = 0;
        } else {
          // Reached the end, result is current level
          _completeTest(VisionConstants.snellenLevels[_currentLevelIndex]);
          return;
        }
      } else {
        // Failed this level, result is previous level
        final resultLevel = _currentLevelIndex > 0
            ? VisionConstants.snellenLevels[_currentLevelIndex - 1]
            : '< 6/60';
        _completeTest(resultLevel);
        return;
      }
    } else if (_consecutiveWrong >= VisionConstants.earlyStopThreshold) {
      // Early stop: 3 consecutive wrong answers
      final resultLevel = _currentLevelIndex > 0
          ? VisionConstants.snellenLevels[_currentLevelIndex - 1]
          : '< 6/60';
      _completeTest(resultLevel);
      return;
    }

    // Generate new direction for next trial
    _generateNewDirection();
    notifyListeners();
  }

  /// Complete the test and store result
  void _completeTest(String result) {
    _isTestComplete = true;
    _currentResult = result;

    // Create EyeResult
    final eyeResult = EyeResult(
      snellenFraction: result,
      testDate: DateTime.now(),
    );

    // Store based on which eye was tested
    if (_currentEye == 'left') {
      _leftEyeResult = eyeResult;
    } else if (_currentEye == 'right') {
      _rightEyeResult = eyeResult;
    } else {
      _bothEyesResult = eyeResult;
    }

    notifyListeners();
  }

  /// Get complete test result
  TestResult? getTestResult() {
    if (_testType == 'near' && _bothEyesResult != null) {
      return TestResult(
        testType: 'near',
        testDate: DateTime.now(),
        bothEyes: _bothEyesResult,
      );
    } else if (_testType == 'distance' &&
        _leftEyeResult != null &&
        _rightEyeResult != null) {
      return TestResult(
        testType: 'distance',
        testDate: DateTime.now(),
        leftEye: _leftEyeResult,
        rightEye: _rightEyeResult,
      );
    }
    return null;
  }

  /// Reset for new test
  void reset() {
    _currentLevelIndex = 0;
    _totalAtLevel = 0;
    _correctAtLevel = 0;
    _consecutiveWrong = 0;
    _isTestComplete = false;
    _currentResult = null;
    _leftEyeResult = null;
    _rightEyeResult = null;
    _bothEyesResult = null;
    notifyListeners();
  }

  /// Calculate current optotype size
  double getCurrentOptotypeSize() {
    final currentSnellen = VisionConstants.snellenLevels[_currentLevelIndex];
    final arcmin = VisionConstants.snellenToArcmin[currentSnellen] ?? 5.0;
    final radians = arcmin * (pi / 180.0 / 60.0);
    final sizeMm = _distanceMm * tan(radians);
    return sizeMm * _pixelsPerMm;
  }
}
