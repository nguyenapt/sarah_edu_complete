import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LevelUpScreen extends StatelessWidget {
  final String oldLevel;
  final String newLevel;

  const LevelUpScreen({
    super.key,
    required this.oldLevel,
    required this.newLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation và icon
            const Icon(
              Icons.emoji_events,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 32),
            
            // Text chào mừng
            const Text(
              'Chúc mừng!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Level transition
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLevelBadge(oldLevel),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                _buildLevelBadge(newLevel, isNew: true),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Bạn đã lên cấp độ $newLevel!',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tiếp tục học tập để nâng cao trình độ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            const Spacer(),
            
            // Nút tiếp tục ở dưới cùng
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(String level, {bool isNew = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isNew ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          level,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isNew ? AppTheme.primaryColor : Colors.white,
          ),
        ),
      ),
    );
  }
}

