import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/level_model.dart';
import '../../core/services/firestore_service.dart';
import '../../models/unit_model.dart';
import '../../providers/language_provider.dart';
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
  LevelModel? _level;
  List<UnitModel> _units = [];
  bool _isLoading = true;

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
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                            Text(
                              _level!.getName(languageCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                  '${_level!.estimatedHours} giờ',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Units List
                  Text(
                    'Các bài học',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_units.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Chưa có unit nào'),
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
                  '${unit.estimatedTime} phút',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${unit.lessons.length} bài học',
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


