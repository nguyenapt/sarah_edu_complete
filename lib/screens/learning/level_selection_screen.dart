import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/level_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/level_skip_test_service.dart';
import '../../models/unit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../level_skip/level_skip_test_screen.dart';
import 'unit_list_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String levelId;
  final LevelModel? levelModel;

  const LevelSelectionScreen({
    super.key,
    required this.levelId,
    this.levelModel,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LevelSkipTestService _levelSkipTestService = LevelSkipTestService();
  LevelModel? _level;
  List<UnitModel> _units = [];
  bool _isLoading = true;
  bool _isLevelLocked = false;
  bool _canSkipLevel = false;
  bool _hasDailyLimit = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load level if not provided
      if (widget.levelModel != null) {
        _level = widget.levelModel;
      } else {
        _level = await _firestoreService.getLevel(widget.levelId);
      }

      // Load units
      final units = await _firestoreService.getUnitsByLevel(widget.levelId);
      
      // Check if level is locked and if user can skip
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final currentLevel = authProvider.user!.currentLevel;
        final nextLevel = _levelSkipTestService.getNextLevel(currentLevel);
        
        _isLevelLocked = currentLevel != null && 
            currentLevel.toUpperCase() != widget.levelId.toUpperCase();
        _canSkipLevel = _isLevelLocked && 
            nextLevel != null && 
            nextLevel.toUpperCase() == widget.levelId.toUpperCase();
        
        if (_canSkipLevel) {
          // Check daily limit
          _hasDailyLimit = await _levelSkipTestService.checkDailyLimit(
            authProvider.user!.id,
          );
        }
      }

      setState(() {
        _units = units;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingData(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _handleLevelSkipTest() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseLogin),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Check daily limit again
    final hasLimit = await _levelSkipTestService.checkDailyLimit(
      authProvider.user!.id,
    );
    
    if (hasLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyLimitReached),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Navigate to level skip test screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSkipTestScreen(
          targetLevel: widget.levelId,
        ),
      ),
    );
    
    // If test passed and level was unlocked, reload data
    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_level != null 
            ? _level!.getName(languageCode)
            : 'Level ${widget.levelId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Info Card
                  if (_level != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _level!.getName(languageCode),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (_isLevelLocked)
                                  Icon(
                                    Icons.lock,
                                    color: Colors.grey[600],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _level!.getDescription(languageCode),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.book,
                                  '${_level!.totalUnits} Units',
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.access_time,
                                  '${_level!.estimatedHours} ${AppLocalizations.of(context)!.hours}',
                                ),
                              ],
                            ),
                            // Level Skip Test Button
                            if (_canSkipLevel) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _hasDailyLimit ? null : _handleLevelSkipTest,
                                  icon: const Icon(Icons.flash_on),
                                  label: Text(
                                    AppLocalizations.of(context)!.skipToLevel(widget.levelId),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_hasDailyLimit)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    AppLocalizations.of(context)!.dailyLimitReached,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Units List
                  Text(
                    AppLocalizations.of(context)!.lessonsList,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_units.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(AppLocalizations.of(context)!.noUnits),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        final unit = _units[index];
                        return _buildUnitCard(unit, index);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildUnitCard(UnitModel unit, int index) {
    final isLocked = index > 0; // Unit đầu tiên unlock, các unit khác cần hoàn thành unit trước
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? Colors.grey[300]
              : AppTheme.levelColors[widget.levelId] ?? AppTheme.primaryColor,
          child: isLocked
              ? Icon(Icons.lock, color: Colors.grey[600])
              : Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          unit.getTitle(languageCode),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(unit.getDescription(languageCode)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${unit.estimatedTime} ${AppLocalizations.of(context)!.minutes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.lessonsCount(unit.lessons.length),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isLocked
            ? Icon(Icons.lock, color: Colors.grey[400])
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitListScreen(
                      unit: unit,
                    ),
                  ),
                );
              },
      ),
    );
  }
}


