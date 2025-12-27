import 'package:flutter/material.dart';
import 'welcome_screen_1.dart';
import 'welcome_screen_2.dart';
import 'welcome_screen_3.dart';

class WelcomeFlow extends StatefulWidget {
  const WelcomeFlow({super.key});

  @override
  State<WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<WelcomeFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  void _skipToLast() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        WelcomeScreen1(
          onNext: _nextPage,
          onSkip: _skipToLast,
        ),
        WelcomeScreen2(
          onNext: _nextPage,
          onPrevious: _previousPage,
          onSkip: _skipToLast,
        ),
        WelcomeScreen3(
          onPrevious: _previousPage,
        ),
      ],
    );
  }
}
