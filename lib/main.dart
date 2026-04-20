import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'core/cache/cache_bootstrap.dart';
import 'core/ads/ad_policy.dart';
import 'core/ads/ads_factory.dart';
import 'core/ads/ads_manager.dart';
import 'core/ads/ads_route_observer.dart';
import 'core/repositories/catalog_repository.dart';
import 'core/widgets/app_update_prompt.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome/welcome_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheBootstrap.init();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
  }

  // Ensure Mobile Ads SDK is initialized before any ad widget loads.
  // Ads are mobile-only (Android/iOS) and disabled on web/desktop.
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('❌ MobileAds initialize failed: $e');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AdsManager _adsManager;
  late final AdsRouteObserver _adsObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _adsManager = AdsManager(
      factory: AdsFactory(),
      policy: AdPolicy(
        minInterstitialInterval: const Duration(minutes: 1, seconds: 30),
      ),
    );
    _adsObserver = AdsRouteObserver(_adsManager);
    _adsManager.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppUpdateCoordinator.checkAndPrompt(context, fromResume: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AdsManager>.value(value: _adsManager),
        Provider(create: (_) => CatalogRepository()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Sarah Edu Complete',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorObservers: [_adsObserver],
            home: const WelcomeWrapper(),
          );
        },
      ),
    );
  }
}
