import 'package:flutter/material.dart';

/// Small persistent badge showing distance during test
/// Positioned in bottom-right corner with color-coded status
/// Updated with flexible distance tolerance
class DistanceBadgeWidget extends StatelessWidget {
  final double currentDistanceCm;
  final double targetDistanceCm;
  final double toleranceCm;
  final Color themeColor;

  const DistanceBadgeWidget({
    super.key,
    required this.currentDistanceCm,
    required this.targetDistanceCm,
    required this.toleranceCm,
    this.themeColor = Colors.blue,
  });

  bool get _isCorrectDistance {
    if (currentDistanceCm <= 0) return false;
    
    // Use more flexible tolerance based on target distance
    double actualTolerance;
    
    if (targetDistanceCm <= 100) {
      // Near distance (40cm): Allow 30-60cm range
      actualTolerance = 20.0;
    } else {
      // Far distance (200cm): Allow 150-250cm range
      actualTolerance = 50.0;
    }
    
    final minDistance = targetDistanceCm - actualTolerance;
    final maxDistance = targetDistanceCm + actualTolerance;
    
    return currentDistanceCm >= minDistance && currentDistanceCm <= maxDistance;
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = currentDistanceCm > 0
        ? currentDistanceCm >= 100
            ? '${(currentDistanceCm / 100).toStringAsFixed(1)}m'
            : '${currentDistanceCm.toStringAsFixed(0)}cm'
        : '--';

    final backgroundColor = _isCorrectDistance ? Colors.green : Colors.red;

    return Positioned(
      bottom: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCorrectDistance ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              distanceText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}