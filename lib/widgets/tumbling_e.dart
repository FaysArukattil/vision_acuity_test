import 'dart:math';
import 'package:flutter/material.dart';

/// Tumbling E Optotype Widget
/// The "E" can face 4 directions: right (0°), down (90°), left (180°), up (270°)
class TumblingE extends StatelessWidget {
  final double size; // Size in pixels
  final int direction; // 0=right, 1=down, 2=left, 3=up
  final Color color;

  const TumblingE({
    super.key,
    required this.size,
    required this.direction,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: direction * (pi / 2), // Rotate based on direction
      child: CustomPaint(
        size: Size(size, size),
        painter: _EPainter(color: color),
      ),
    );
  }
}

/// Custom Painter for drawing the "E" shape
/// Based on WHO standards: E has a 5:1 aspect ratio
/// - Total width: 5 units
/// - Total height: 5 units
/// - Bar width: 1 unit
/// - Gap width: 1 unit
class _EPainter extends CustomPainter {
  final Color color;

  _EPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final unit = size.width / 5.0; // Each unit is 1/5 of total width

    // Draw the E shape (when facing right, before rotation)
    // The E consists of:
    // 1. A vertical bar on the left (1 unit wide, 5 units tall)
    // 2. Three horizontal bars (each 5 units wide, 1 unit tall)
    //    - Top bar
    //    - Middle bar
    //    - Bottom bar

    // Vertical bar (left side)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, unit, size.height),
      paint,
    );

    // Top horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, unit),
      paint,
    );

    // Middle horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(0, unit * 2, size.width, unit),
      paint,
    );

    // Bottom horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(0, unit * 4, size.width, unit),
      paint,
    );
  }

  @override
  bool shouldRepaint(_EPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
