import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Nếu chưa đăng nhập, hiển thị login/register
          if (!authProvider.isAuthenticated) {
            return _buildAuthSection(context, authProvider);
          }

          // Nếu đã đăng nhập, hiển thị settings
          return _buildSettingsSection(context, authProvider);
        },
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.account_circle,
            size: 100,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.loginToSync,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.loginToSaveProgress,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.login),
            label: Text(AppLocalizations.of(context)!.login),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: Text(AppLocalizations.of(context)!.register),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          // Language Selection - Available even when not logged in
          Card(
            child: _buildLanguageTile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 35,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName != null && user!.displayName!.isNotEmpty
                            ? user.displayName!
                            : AppLocalizations.of(context)!.user,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.stats,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        Icons.local_fire_department,
                        '${user?.streak ?? 0}',
                        AppLocalizations.of(context)!.daysStreak,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        Icons.star,
                        '${user?.totalXP ?? 0}',
                        AppLocalizations.of(context)!.xp,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        Icons.school,
                        user?.currentLevel ?? 'A1',
                        AppLocalizations.of(context)!.levelLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Settings Options
        _buildSettingsTile(
          context,
          icon: Icons.person,
          title: AppLocalizations.of(context)!.accountInfo,
          onTap: () {
            // Navigate to profile
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.notifications,
          title: AppLocalizations.of(context)!.notifications,
          onTap: () {
            // Navigate to notifications settings
          },
        ),
        _buildLanguageTile(context),
        _buildThemeTile(context),
        _buildSettingsTile(
          context,
          icon: Icons.help_outline,
          title: AppLocalizations.of(context)!.help,
          onTap: () {
            // Navigate to help
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: AppLocalizations.of(context)!.about,
          onTap: () {
            // Show about dialog
          },
        ),
        const Divider(),
        _buildSettingsTile(
          context,
          icon: Icons.logout,
          title: AppLocalizations.of(context)!.logout,
          titleColor: Colors.red,
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.logout),
                content: Text(AppLocalizations.of(context)!.logoutConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      AppLocalizations.of(context)!.logout,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await authProvider.signOut();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentLanguage = languageProvider.availableLanguages.firstWhere(
          (lang) => lang['code'] == languageProvider.currentLanguageCode,
          orElse: () => languageProvider.availableLanguages[0],
        );

        return _LanguageSelectorTile(
          currentLanguage: currentLanguage,
          availableLanguages: languageProvider.availableLanguages,
          currentLanguageCode: languageProvider.currentLanguageCode,
          onLanguageSelected: (languageCode) async {
            await languageProvider.setLanguage(languageCode);
          },
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final availableThemes = [
          {'mode': 'light', 'name': 'Sáng', 'icon': Icons.light_mode},
          {'mode': 'dark', 'name': 'Tối', 'icon': Icons.dark_mode},
          {'mode': 'system', 'name': 'Hệ thống', 'icon': Icons.phone_android},
        ];

        final currentTheme = availableThemes.firstWhere(
          (theme) => theme['mode'] == themeProvider.currentThemeModeString,
          orElse: () => availableThemes[2],
        );

        return _ThemeSelectorTile(
          currentTheme: currentTheme,
          availableThemes: availableThemes,
          currentThemeModeString: themeProvider.currentThemeModeString,
          onThemeSelected: (themeMode) async {
            await themeProvider.setThemeMode(themeMode);
          },
        );
      },
    );
  }
}

// Separate StatefulWidget để quản lý ExpansionTile state
class _LanguageSelectorTile extends StatefulWidget {
  final Map<String, String> currentLanguage;
  final List<Map<String, String>> availableLanguages;
  final String currentLanguageCode;
  final Function(String) onLanguageSelected;

  const _LanguageSelectorTile({
    required this.currentLanguage,
    required this.availableLanguages,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageSelectorTile> createState() => _LanguageSelectorTileState();
}

class _LanguageSelectorTileState extends State<_LanguageSelectorTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Sử dụng key để force rebuild khi _isExpanded thay đổi
    return ExpansionTile(
      key: ValueKey('language_tile_$_isExpanded'),
      leading: Icon(Icons.language, color: AppTheme.primaryColor),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text('${widget.currentLanguage['flag']} ${widget.currentLanguage['name']}'),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        if (mounted) {
          setState(() {
            _isExpanded = expanded;
          });
        }
      },
      children: widget.availableLanguages.map((lang) {
        final isSelected = lang['code'] == widget.currentLanguageCode;
        return ListTile(
          leading: Text(
            lang['flag'] ?? '',
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(lang['name'] ?? ''),
          trailing: isSelected
              ? Icon(Icons.check, color: AppTheme.primaryColor)
              : null,
          selected: isSelected,
          onTap: () async {
            // Đóng ExpansionTile ngay lập tức
            if (_isExpanded && mounted) {
              setState(() {
                _isExpanded = false;
              });
              // Đợi một chút để animation đóng hoàn thành
              await Future.delayed(const Duration(milliseconds: 300));
            }
            // Đổi ngôn ngữ
            if (mounted) {
              await widget.onLanguageSelected(lang['code']!);
            }
          },
        );
      }).toList(),
    );
  }
}

// Separate StatefulWidget để quản lý Theme ExpansionTile state
class _ThemeSelectorTile extends StatefulWidget {
  final Map<String, dynamic> currentTheme;
  final List<Map<String, dynamic>> availableThemes;
  final String currentThemeModeString;
  final Function(String) onThemeSelected;

  const _ThemeSelectorTile({
    required this.currentTheme,
    required this.availableThemes,
    required this.currentThemeModeString,
    required this.onThemeSelected,
  });

  @override
  State<_ThemeSelectorTile> createState() => _ThemeSelectorTileState();
}

class _ThemeSelectorTileState extends State<_ThemeSelectorTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey('theme_tile_$_isExpanded'),
      leading: Icon(Icons.dark_mode, color: AppTheme.primaryColor),
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Text(widget.currentTheme['name'] ?? ''),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        if (mounted) {
          setState(() {
            _isExpanded = expanded;
          });
        }
      },
      children: widget.availableThemes.map((theme) {
        final isSelected = theme['mode'] == widget.currentThemeModeString;
        return ListTile(
          leading: Icon(
            theme['icon'] as IconData,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
          title: Text(theme['name'] ?? ''),
          trailing: isSelected
              ? Icon(Icons.check, color: AppTheme.primaryColor)
              : null,
          selected: isSelected,
          onTap: () async {
            // Đóng ExpansionTile ngay lập tức
            if (_isExpanded && mounted) {
              setState(() {
                _isExpanded = false;
              });
              // Đợi một chút để animation đóng hoàn thành
              await Future.delayed(const Duration(milliseconds: 300));
            }
            // Đổi theme
            if (mounted) {
              await widget.onThemeSelected(theme['mode'] as String);
            }
          },
        );
      }).toList(),
    );
  }
}


