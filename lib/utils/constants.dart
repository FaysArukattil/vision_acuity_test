/// WHO Standard Constants for Vision Testing
class VisionConstants {
  // Prevent instantiation
  VisionConstants._();

  /// Standard Snellen fractions in order from worst to best
  static const List<String> snellenLevels = [
    '6/60',
    '6/48',
    '6/38',
    '6/30',
    '6/24',
    '6/19',
    '6/15',
    '6/12',
    '6/9.5',
    '6/7.5',
    '6/6',
    '6/4.8',
  ];

  /// Map Snellen fractions to visual angle in arcminutes
  /// Formula: arcmin = (denominator / 6) * 5
  /// 6/6 = 5 arcmin (normal vision)
  /// 6/60 = 50 arcmin
  static const Map<String, double> snellenToArcmin = {
    '6/60': 50.0,
    '6/48': 40.0,
    '6/38': 31.67,
    '6/30': 25.0,
    '6/24': 20.0,
    '6/19': 15.83,
    '6/15': 12.5,
    '6/12': 10.0,
    '6/9.5': 7.92,
    '6/7.5': 6.25,
    '6/6': 5.0,
    '6/4.8': 4.0,
  };

  /// Convert Snellen to decimal acuity
  static const Map<String, double> snellenToDecimal = {
    '6/60': 0.1,
    '6/48': 0.125,
    '6/38': 0.158,
    '6/30': 0.2,
    '6/24': 0.25,
    '6/19': 0.316,
    '6/15': 0.4,
    '6/12': 0.5,
    '6/9.5': 0.632,
    '6/7.5': 0.8,
    '6/6': 1.0,
    '6/4.8': 1.25,
  };

  /// Test distances in millimeters
  static const double nearDistanceMm = 400.0; // 40cm
  static const double farDistanceMm = 2000.0; // 2m (200cm)

  /// Credit card standard size for calibration (ISO/IEC 7810 ID-1)
  static const double creditCardWidthMm = 85.6;
  static const double creditCardHeightMm = 53.98;

  /// Test configuration
  static const int trialsPerLevel = 5; // Number of trials per Snellen level
  static const int passThreshold = 3; // Need 3/5 correct to pass
  static const int earlyStopThreshold = 3; // Stop after 3 consecutive wrong

  /// Tumbling E directions
  static const int directionRight = 0;
  static const int directionDown = 1;
  static const int directionLeft = 2;
  static const int directionUp = 3;

  /// Color thresholds for results
  static const double excellentThreshold = 100.0; // >= 100% (6/6 or better)
  static const double goodThreshold = 80.0; // >= 80%
  static const double moderateThreshold = 50.0; // >= 50%
  static const double poorThreshold = 30.0; // >= 30%
  /// Default pixels per mm (assuming ~160 DPI baseline for logical pixels)
  /// 160 DPI / 25.4 mm/inch ≈ 6.3 px/mm
  static const double defaultPixelsPerMm = 6.3;
}
