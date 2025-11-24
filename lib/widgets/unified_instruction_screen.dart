import 'package:flutter/material.dart';

/// Data model for instruction content
class InstructionData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InstructionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Unified instruction screen with swipeable pages
/// Replaces multiple separate instruction screens
class UnifiedInstructionScreen extends StatefulWidget {
  final String testType; // 'near' or 'distance'
  final List<InstructionData> instructions;
  final VoidCallback onStart;
  final String appBarTitle;

  const UnifiedInstructionScreen({
    super.key,
    required this.testType,
    required this.instructions,
    required this.onStart,
    required this.appBarTitle,
  });

  @override
  State<UnifiedInstructionScreen> createState() => _UnifiedInstructionScreenState();
}

class _UnifiedInstructionScreenState extends State<UnifiedInstructionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.instructions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - start test
      widget.onStart();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.testType == 'near' 
        ? Colors.green.shade700 
        : Colors.blue.shade700;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Page indicators
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.instructions.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? themeColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Swipeable instruction pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.instructions.length,
                  itemBuilder: (context, index) {
                    return _buildInstructionPage(widget.instructions[index]);
                  },
                ),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeColor,
                            side: BorderSide(color: themeColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentPage > 0 ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage < widget.instructions.length - 1
                              ? 'Next'
                              : 'Start Test',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionPage(InstructionData instruction) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: instruction.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                instruction.icon,
                size: 64,
                color: instruction.color,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              instruction.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: instruction.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              instruction.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
