import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/welcome_service.dart';
import '../../core/ads/ads_manager.dart';
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
      // Cold start only: show app-open after onboarding has been completed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final ads = Provider.of<AdsManager>(context, listen: false);
          ads.maybeShowAppOpen();
        } catch (_) {}
      });
      return const MainNavigation();
    }

    return const WelcomeFlow();
  }
}

