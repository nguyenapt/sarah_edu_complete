import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

import 'home/home_screen.dart';
import 'practice/practice_screen.dart';
import 'review/review_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'auth/login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool? _lastAuthState;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    // Reset index nếu auth state thay đổi
    if (_lastAuthState != null && _lastAuthState != isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = 0; // Reset về Home khi auth state thay đổi
          });
        }
      });
    }
    _lastAuthState = isAuthenticated;

    // Build screens list - luôn có ReviewScreen (guest user sẽ thấy màn hình yêu cầu đăng nhập)
    final screens = <Widget>[
      const HomeScreen(),
      const PracticeScreen(),
      const ReviewScreen(),
      const ProgressScreen(),
      const SettingsScreen(),
    ];

    // Build navigation items - hiển thị tất cả tabs
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.fitness_center),
        label: AppLocalizations.of(context)!.practice,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.refresh, color: isAuthenticated ? null : Colors.grey[400]),
        label: 'Ôn Tập', // TODO: Thêm vào localization
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.trending_up, color: isAuthenticated ? null : Colors.grey[400]),
        label: AppLocalizations.of(context)!.progress,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: AppLocalizations.of(context)!.settings,
      ),
    ];

    // Map index từ navigation bar sang screens list
    // Tất cả users đều có cùng structure: 0=Home, 1=Practice, 2=Review, 3=Progress, 4=Settings
    int getScreenIndex(int navIndex) {
      return navIndex;
    }

    // Map index từ screens list sang navigation bar
    int getNavIndex(int screenIndex) {
      return screenIndex;
    }

    // Điều chỉnh currentIndex khi auth state thay đổi
    int adjustedIndex = getNavIndex(_currentIndex);
    if (adjustedIndex >= items.length) {
      adjustedIndex = 0;
      _currentIndex = 0; // Reset về Home
    }

    // Đảm bảo screenIndex hợp lệ
    int screenIndex = getScreenIndex(adjustedIndex);
    if (screenIndex >= screens.length) {
      screenIndex = 0;
      _currentIndex = 0; // Reset về Home
    }

    return Scaffold(
      body: screens[screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: adjustedIndex,
        onTap: (index) {
          // Hiển thị thông báo yêu cầu đăng nhập cho guest user khi bấm vào Review hoặc Progress
          if (!isAuthenticated) {
            // 0=Home, 1=Practice, 2=Review, 3=Progress, 4=Settings
            if (index == 2 || index == 3) {
              // Hiển thị thông báo yêu cầu đăng nhập
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Vui lòng đăng nhập để sử dụng tính năng này'),
                  action: SnackBarAction(
                    label: 'Đăng nhập',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
              // Vẫn cho chuyển tab (không return)
            }
          }
          
          setState(() {
            _currentIndex = getScreenIndex(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}


