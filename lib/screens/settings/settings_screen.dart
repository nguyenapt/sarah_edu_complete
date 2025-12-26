import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
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
            'Đăng nhập để đồng bộ dữ liệu',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để lưu tiến độ học tập và\nđồng bộ trên nhiều thiết bị',
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
            label: const Text('Đăng nhập'),
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
            label: const Text('Đăng ký'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
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
                  radius: 30,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
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
                  'Thống kê',
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
                        'Ngày liên tiếp',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        Icons.star,
                        '${user?.totalXP ?? 0}',
                        'XP',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        Icons.school,
                        user?.currentLevel ?? 'A1',
                        'Level',
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
          title: 'Thông tin tài khoản',
          onTap: () {
            // Navigate to profile
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.notifications,
          title: 'Thông báo',
          onTap: () {
            // Navigate to notifications settings
          },
        ),
        _buildLanguageTile(context),
        _buildSettingsTile(
          context,
          icon: Icons.dark_mode,
          title: 'Giao diện',
          onTap: () {
            // Navigate to theme settings
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.help_outline,
          title: 'Trợ giúp',
          onTap: () {
            // Navigate to help
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: 'Về ứng dụng',
          onTap: () {
            // Show about dialog
          },
        ),
        const Divider(),
        _buildSettingsTile(
          context,
          icon: Icons.logout,
          title: 'Đăng xuất',
          titleColor: Colors.red,
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Đăng xuất'),
                content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
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

        return ExpansionTile(
          leading: Icon(Icons.language, color: AppTheme.primaryColor),
          title: Text(AppLocalizations.of(context)!.language),
          subtitle: Text('${currentLanguage['flag']} ${currentLanguage['name']}'),
          children: languageProvider.availableLanguages.map((lang) {
            final isSelected = lang['code'] == languageProvider.currentLanguageCode;
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
                await languageProvider.setLanguage(lang['code']!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}


