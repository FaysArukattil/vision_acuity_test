import 'package:flutter/material.dart';

/// Warning Banner Widget
/// Displays a disclaimer that this is a screening tool, not a diagnosis
class WarningBanner extends StatelessWidget {
  final String message;

  const WarningBanner({
    super.key,
    this.message = 'This is a screening tool. Consult an eye care professional for accurate diagnosis.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(
          color: Colors.amber.shade700,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
