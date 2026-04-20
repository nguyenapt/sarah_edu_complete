import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/welcome_service.dart';
import '../../core/ads/ads_manager.dart';
import '../../core/widgets/app_update_prompt.dart';
import '../../providers/auth_provider.dart';
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
  bool _mainShellCallbacksScheduled = false;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
  }

  void _runMainShellCallbacksOnce() {
    if (_mainShellCallbacksScheduled || !mounted) return;
    _mainShellCallbacksScheduled = true;
    try {
      final ads = Provider.of<AdsManager>(context, listen: false);
      ads.maybeShowAppOpen();
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      AppUpdateCoordinator.checkAndPrompt(context);
    });
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
      return Selector<AuthProvider, bool>(
        selector: (_, auth) => auth.isLoading,
        builder: (context, authBootstrapping, _) {
          if (authBootstrapping) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _runMainShellCallbacksOnce();
          });
          return const MainNavigation();
        },
      );
    }

    return const WelcomeFlow();
  }
}

