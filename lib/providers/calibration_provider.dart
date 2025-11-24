import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Calibration Provider
/// Manages screen calibration using credit card sizing
class CalibrationProvider with ChangeNotifier {
  double? _pixelsPerMm;
  bool _isCalibrated = false;

  double? get pixelsPerMm => _pixelsPerMm;
  bool get isCalibrated => _isCalibrated;

  /// Load calibration from storage
  Future<void> loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getDouble('pixels_per_mm');
    if (savedValue != null) {
      _pixelsPerMm = savedValue;
      _isCalibrated = true;
      notifyListeners();
    }
  }

  /// Set calibration value
  Future<void> setCalibration(double creditCardPixelWidth) async {
    // Credit card width is 85.6mm (ISO/IEC 7810 ID-1 standard)
    const double creditCardWidthMm = 85.6;
    _pixelsPerMm = creditCardPixelWidth / creditCardWidthMm;
    _isCalibrated = true;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pixels_per_mm', _pixelsPerMm!);

    notifyListeners();
  }

  /// Clear calibration
  Future<void> clearCalibration() async {
    _pixelsPerMm = null;
    _isCalibrated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pixels_per_mm');

    notifyListeners();
  }

  /// Reset for new test
  void reset() {
    // Don't clear calibration, just mark as not calibrated for this session
    _isCalibrated = false;
    notifyListeners();
  }
}
