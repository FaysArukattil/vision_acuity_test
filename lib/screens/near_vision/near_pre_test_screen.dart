import 'package:flutter/material.dart';
import 'near_test_screen.dart';

class NearPreTestScreen extends StatelessWidget {
  const NearPreTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600 || constraints.maxHeight < 600;
          final iconSize = isSmallScreen ? 80.0 : 100.0;
          final titleSize = isSmallScreen ? 26.0 : 32.0;
          final subtitleSize = isSmallScreen ? 14.0 : 16.0;
          final horizontalPadding = isSmallScreen ? 24.0 : 48.0;

          return Container(
            color: Colors.green.shade700,
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        Text(
                          'KEEP BOTH EYES OPEN',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'The camera will measure and confirm\n40cm distance automatically',
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 32 : 48),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NearTestScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Start Distance Measurement',
                                style:
                                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
