import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_provider.dart';
import '../../widgets/circular_progress_chart.dart';
import '../../widgets/warning_banner.dart';
import '../distance_selection_screen.dart';

class DistanceResultsScreen extends StatelessWidget {
  const DistanceResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<TestProvider>();
    final leftResult = testProvider.leftEyeResult;
    final rightResult = testProvider.rightEyeResult;

    if (leftResult == null || rightResult == null) {
      return const Scaffold(
        body: Center(child: Text('No results available')),
      );
    }

    final avgPercentage = (leftResult.percentage + rightResult.percentage) / 2;
    final hasDifference =
        (leftResult.percentage - rightResult.percentage).abs() > 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Distance Vision Results',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Both eyes comparison
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left eye
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Left Eye',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CircularProgressChart(
                            percentage: leftResult.percentage,
                            label: leftResult.snellenFraction,
                            color: leftResult.color,
                            size: 140,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            leftResult.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: leftResult.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right eye
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Right Eye',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CircularProgressChart(
                            percentage: rightResult.percentage,
                            label: rightResult.snellenFraction,
                            color: rightResult.color,
                            size: 140,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rightResult.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: rightResult.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Average
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Average Visual Acuity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${avgPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDifference) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Significant difference detected between eyes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Recommendation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Recommendation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getRecommendation(avgPercentage, hasDifference),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Warning banner
                const WarningBanner(),
                const SizedBox(height: 24),
                // Test again button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Reset and go back to distance selection
                      context.read<TestProvider>().reset();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DistanceSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Test Again',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRecommendation(double percentage, bool hasDifference) {
    String baseRecommendation;

    if (percentage >= 80.0) {
      baseRecommendation =
          'Your distance vision is good! Continue regular eye checkups to maintain your vision health.';
    } else if (percentage >= 50.0) {
      baseRecommendation =
          'Your distance vision could be improved. Consider scheduling an appointment with an eye care professional for a comprehensive examination.';
    } else if (percentage >= 30.0) {
      baseRecommendation =
          'We strongly recommend consulting an eye care professional soon for a thorough examination and possible corrective measures.';
    } else {
      baseRecommendation =
          'Please consult an eye care professional as soon as possible. Your vision may require immediate attention.';
    }

    if (hasDifference) {
      baseRecommendation +=
          '\n\nNote: There is a significant difference between your eyes. This should be evaluated by a professional.';
    }

    return baseRecommendation;
  }
}
