import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/common/practice_top_app_bar.dart';
import '../settings/settings_screen.dart';
import '../main_navigation.dart';
import '../../widgets/common/guest_locked_view.dart';
import '../auth/register_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  WeakSkillStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final progress = await _firestoreService.getUserProgress(authProvider.user!.id);
      if (mounted) {
        setState(() {
          _stats = progress?.weakSkillStats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final title = AppLocalizations.of(context)!.progressTitle;
            if (!authProvider.isAuthenticated) {
              return AppBar(
                backgroundColor: const Color(0xFFF4F6FF),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14304F),
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
              );
            }
            return PracticeTopAppBar(
              title: title,
              onAvatarTap: () {
                final scope = MainNavigationScope.of(context);
                if (scope != null) {
                  scope.goToTab(4);
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            );
          },
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Nếu chưa đăng nhập, hiển thị empty state với nút đăng nhập
          if (!authProvider.isAuthenticated) {
            final loc = AppLocalizations.of(context)!;
            return GuestLockedView(
              title: loc.loginToSync,
              subtitle: loc.loginToSaveProgress,
              onLogin: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              onRegister: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
            );
          }

          // Nếu đã đăng nhập, hiển thị progress content
          return _buildProgressContent(context);
        },
      ),
    );
  }

  // Removed legacy guest login-required view (replaced by `GuestLockedView`).

  Widget _buildProgressContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final values = _buildSkillValues(_stats);
    if (values.every((value) => value == 0)) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noProgressData,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: AppTheme.primaryColor.withOpacity(0.2),
                            borderColor: AppTheme.primaryColor,
                            entryRadius: 3,
                            dataEntries: values
                                .map((value) => RadarEntry(value: value))
                                .toList(),
                          ),
                        ],
                        radarBackgroundColor: Colors.transparent,
                        radarBorderData: BorderSide(color: Colors.grey[300]!),
                        tickCount: 5,
                        ticksTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        titlePositionPercentageOffset: 0.12,
                        getTitle: (index, angle) {
                          const labels = ['Listening', 'Reading', 'Writing', 'Speaking'];
                          return RadarChartTitle(text: labels[index]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Skills (0-10 scale)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _buildSkillValues(WeakSkillStats? stats) {
    final skillMap = <String, double>{
      'listening': 0,
      'reading': 0,
      'writing': 0,
      'speaking': 0,
    };

    if (stats != null) {
      for (final item in stats.skillTypes) {
        final key = item.id.toLowerCase();
        if (skillMap.containsKey(key)) {
          skillMap[key] = (item.accuracy * 10).clamp(0, 10).toDouble();
        }
      }
    }

    return [
      skillMap['listening'] ?? 0,
      skillMap['reading'] ?? 0,
      skillMap['writing'] ?? 0,
      skillMap['speaking'] ?? 0,
    ];
  }
}


