import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/streak/streak_service.dart';

/// 连续打卡卡片
class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int currentStreak = 0;
  bool hasPracticedToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      currentStreak = StreakService.currentStreak;
      hasPracticedToday = StreakService.hasPracticedToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.streakFlame.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.streakFlame.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '连续打卡',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.streakFlame,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '天',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hasPracticedToday
                  ? AppTheme.accentGreen.withOpacity(0.2)
                  : AppTheme.streakFlame.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hasPracticedToday ? '今日已打卡' : '今日未打卡',
              style: TextStyle(
                fontSize: 12,
                color: hasPracticedToday
                    ? AppTheme.accentGreen
                    : AppTheme.streakFlame,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
