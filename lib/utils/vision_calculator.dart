import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';

/// Vision Calculator - WHO Standard Calculations
class VisionCalculator {
  // Prevent instantiation
  VisionCalculator._();

  /// Calculate optotype size in millimeters using WHO formula
  /// sizeMm = distanceMm × tan(arcminutes × π/180/60)
  static double getOptotypeSizeMm(String snellenFraction, double distanceMm) {
    final arcmin = VisionConstants.snellenToArcmin[snellenFraction] ?? 5.0;
    final radians = arcmin * (pi / 180.0 / 60.0);
    return distanceMm * tan(radians);
  }

  /// Calculate optotype size in pixels
  static double getOptotypeSizePixels(
    String snellenFraction,
    double distanceMm,
    double pixelsPerMm,
  ) {
    final sizeMm = getOptotypeSizeMm(snellenFraction, distanceMm);
    return sizeMm * pixelsPerMm;
  }

  /// Calculate pixels per millimeter from calibration
  /// User aligns a credit card on screen, we measure its pixel width
  static double calculatePixelsPerMm(double creditCardPixelWidth) {
    return creditCardPixelWidth / VisionConstants.creditCardWidthMm;
  }

  /// Convert Snellen fraction to percentage (6/6 = 100%)
  static double calculateAcuityPercentage(String snellenFraction) {
    final decimal = VisionConstants.snellenToDecimal[snellenFraction];
    if (decimal == null) return 0.0;
    return decimal * 100.0;
  }

  /// Get description based on acuity percentage
  static String getAcuityDescription(String snellenFraction) {
    final percentage = calculateAcuityPercentage(snellenFraction);
    
    if (percentage >= VisionConstants.excellentThreshold) {
      return 'Excellent';
    } else if (percentage >= VisionConstants.goodThreshold) {
      return 'Good';
    } else if (percentage >= VisionConstants.moderateThreshold) {
      return 'Moderate';
    } else if (percentage >= VisionConstants.poorThreshold) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }

  /// Get color based on acuity percentage
  static Color getAcuityColor(String snellenFraction) {
    final percentage = calculateAcuityPercentage(snellenFraction);
    
    if (percentage >= VisionConstants.excellentThreshold) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= VisionConstants.goodThreshold) {
      return const Color(0xFF8BC34A); // Light Green
    } else if (percentage >= VisionConstants.moderateThreshold) {
      return const Color(0xFFFFC107); // Amber
    } else if (percentage >= VisionConstants.poorThreshold) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  /// Convert Snellen to decimal value
  static double snellenToDecimal(String snellenFraction) {
    return VisionConstants.snellenToDecimal[snellenFraction] ?? 0.0;
  }

  /// Get the next Snellen level (harder)
  static String? getNextLevel(String currentLevel) {
    final index = VisionConstants.snellenLevels.indexOf(currentLevel);
    if (index == -1 || index == VisionConstants.snellenLevels.length - 1) {
      return null;
    }
    return VisionConstants.snellenLevels[index + 1];
  }

  /// Get the previous Snellen level (easier)
  static String? getPreviousLevel(String currentLevel) {
    final index = VisionConstants.snellenLevels.indexOf(currentLevel);
    if (index <= 0) {
      return null;
    }
    return VisionConstants.snellenLevels[index - 1];
  }

  /// Format visual angle in arcminutes
  static String formatArcminutes(String snellenFraction) {
    final arcmin = VisionConstants.snellenToArcmin[snellenFraction];
    if (arcmin == null) return 'N/A';
    return '${arcmin.toStringAsFixed(1)}\'';
  }
}
