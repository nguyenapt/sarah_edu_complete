import 'package:flutter/material.dart';
import '../../core/services/welcome_service.dart';
import 'welcome_flow.dart';
import '../main_navigation.dart';

class WelcomeWrapper extends StatefulWidget {
  const WelcomeWrapper({super.key});

  @override
  State<WelcomeWrapper> createState() => _WelcomeWrapperState();
}

class _WelcomeWrapperState extends State<WelcomeWrapper> {
  bool _isLoading = true;
  bool _hasSeenWelcome = false;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
  }

  Future<void> _checkWelcomeStatus() async {
    final hasSeen = await WelcomeService.hasSeenWelcome();
    setState(() {
      _hasSeenWelcome = hasSeen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasSeenWelcome) {
      return const MainNavigation();
    }

    return const WelcomeFlow();
  }
}

