import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_provider.dart';
import '../../widgets/circular_progress_chart.dart';
import '../../widgets/warning_banner.dart';
import '../../utils/vision_calculator.dart';
import '../distance_selection_screen.dart';

class NearResultsScreen extends StatelessWidget {
  const NearResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<TestProvider>();
    final result = testProvider.bothEyesResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No results available')),
      );
    }

    final percentage = result.percentage;
    final description = result.description;
    final color = result.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: Colors.green.shade700,
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
                  'Near Vision Results',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Circular progress chart
                CircularProgressChart(
                  percentage: percentage,
                  label: result.snellenFraction,
                  color: color,
                  size: 200,
                ),
                const SizedBox(height: 32),
                // Description card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visual Acuity: ${result.snellenFraction}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Decimal: ${VisionCalculator.snellenToDecimal(result.snellenFraction).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        _getRecommendation(percentage),
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
                      backgroundColor: Colors.green.shade700,
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

  String _getRecommendation(double percentage) {
    if (percentage >= 80.0) {
      return 'Your near vision is good! Continue regular eye checkups to maintain your vision health.';
    } else if (percentage >= 50.0) {
      return 'Your near vision could be improved. Consider scheduling an appointment with an eye care professional for a comprehensive examination.';
    } else if (percentage >= 30.0) {
      return 'We strongly recommend consulting an eye care professional soon for a thorough examination and possible corrective measures.';
    } else {
      return 'Please consult an eye care professional as soon as possible. Your vision may require immediate attention.';
    }
  }
}
