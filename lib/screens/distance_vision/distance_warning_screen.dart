import 'package:flutter/material.dart';
import '../../widgets/unified_instruction_screen.dart';
import 'distance_eye_test_screen.dart';

class DistanceWarningScreen extends StatelessWidget {
  const DistanceWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Vision Test'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(
                    color: Colors.amber.shade700,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups,
                      size: 80,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Second Person Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This test requires two people:\n\n'
                      '• Person being tested: Points in the direction of E\n'
                      '• Tester: Swipes on the phone based on pointing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnifiedInstructionScreen(
                          testType: 'distance',
                          appBarTitle: 'Distance Vision Test',
                          instructions: const [
                            InstructionData(
                              icon: Icons.brightness_high,
                              title: 'Maximize Brightness',
                              description:
                                  'Increase your screen brightness to maximum for accurate results',
                              color: Colors.blue,
                            ),
                            InstructionData(
                              icon: Icons.remove_red_eye,
                              title: 'Cover One Eye',
                              description:
                                  'You will test each eye separately by covering the other eye',
                              color: Colors.blue,
                            ),
                            InstructionData(
                              icon: Icons.camera_front,
                              title: 'Camera Distance Check',
                              description:
                                  'Your camera will measure and confirm 2m distance automatically',
                              color: Colors.blue,
                            ),
                          ],
                          onStart: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DistanceEyeTestScreen(eye: 'left'),
                              ),
                            );
                          },
                        ),
                      ),
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
                    'Start Test',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
