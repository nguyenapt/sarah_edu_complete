import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.progressTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Nếu chưa đăng nhập, hiển thị empty state với nút đăng nhập
          if (!authProvider.isAuthenticated) {
            return _buildLoginRequiredView(context);
          }

          // Nếu đã đăng nhập, hiển thị progress content
          return _buildProgressContent(context);
        },
      ),
    );
  }

  Widget _buildLoginRequiredView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.loginToSync,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.loginToSaveProgress,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

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


