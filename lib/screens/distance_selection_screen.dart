import 'package:flutter/material.dart';
import '../widgets/unified_instruction_screen.dart';
import 'distance_vision/distance_warning_screen.dart';
import 'near_vision/near_pre_test_screen.dart';

class DistanceSelectionScreen extends StatelessWidget {
  const DistanceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Test Type'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16.0 : 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Choose Your Test Distance',
                        style: TextStyle(
                          fontSize: constraints.maxWidth < 600 ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: constraints.maxHeight < 600 ? 24 : 48),
                      _buildTestTypeCard(
                        context,
                        constraints: constraints,
                        icon: Icons.phone_android,
                        title: 'Short Distance',
                        subtitle: 'Near Vision Test',
                        description: 'Automatically measured at 40cm using camera',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UnifiedInstructionScreen(
                                testType: 'near',
                                appBarTitle: 'Near Vision Test',
                                instructions: const [
                                  InstructionData(
                                    icon: Icons.brightness_high,
                                    title: 'Maximize Brightness',
                                    description:
                                        'Increase your screen brightness to maximum for accurate results',
                                    color: Colors.green,
                                  ),
                                  InstructionData(
                                    icon: Icons.visibility,
                                    title: 'Keep Both Eyes Open',
                                    description:
                                        'This test measures vision with both eyes open',
                                    color: Colors.green,
                                  ),
                                  InstructionData(
                                    icon: Icons.camera_front,
                                    title: 'Camera Distance Check',
                                    description:
                                        'Your camera will measure and confirm 40cm distance automatically',
                                    color: Colors.green,
                                  ),
                                ],
                                onStart: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NearPreTestScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: constraints.maxHeight < 600 ? 16 : 24),
                      _buildTestTypeCard(
                        context,
                        constraints: constraints,
                        icon: Icons.visibility,
                        title: 'Long Distance',
                        subtitle: 'Distance Vision Test',
                        description: 'Automatically measured at 2m using camera',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DistanceWarningScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestTypeCard(
    BuildContext context, {
    required BoxConstraints constraints,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    final bool isSmallScreen = constraints.maxWidth < 600;
    final double iconSize = isSmallScreen ? 48 : 64;
    final double titleSize = isSmallScreen ? 20 : 24;
    final double subtitleSize = isSmallScreen ? 14 : 16;
    final double descSize = isSmallScreen ? 12 : 14;
    final double cardPadding = isSmallScreen ? 16 : 24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color[600]!, color[800]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              description,
              style: TextStyle(
                fontSize: descSize,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
