import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/local_storage_service.dart';

/// Streak 连续打卡系统
class StreakService {
  static const String _streakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _lastActiveDateKey = 'last_active_date';
  static const String _streakHistoryKey = 'streak_history';
  static const String _streakFreezeCountKey = 'streak_freeze_count';
  static const String _lastStreakFreezeDateKey = 'last_streak_freeze_date';
  
  /// 获取当前连续天数
  static int get currentStreak {
    return LocalStorageService.getSetting<int>(_streakKey, defaultValue: 0) ?? 0;
  }
  
  static set currentStreak(int value) {
    LocalStorageService.setSetting(_streakKey, value);
  }
  
  /// 获取最长连续天数
  static int get longestStreak {
    return LocalStorageService.getSetting<int>(_longestStreakKey, defaultValue: 0) ?? 0;
  }
  
  static set longestStreak(int value) {
    LocalStorageService.setSetting(_longestStreakKey, value);
  }
  
  /// 获取 streak freeze 次数
  static int get streakFreezeCount {
    return LocalStorageService.getSetting<int>(_streakFreezeCountKey, defaultValue: 0) ?? 0;
  }
  
  static set streakFreezeCount(int value) {
    LocalStorageService.setSetting(_streakFreezeCountKey, value);
  }
  
  /// 检查今天的打卡状态
  static bool get hasPracticedToday {
    final lastActive = lastActiveDate;
    if (lastActive == null) return false;
    
    final now = DateTime.now();
    return lastActive.year == now.year &&
           lastActive.month == now.month &&
           lastActive.day == now.day;
  }
  
  /// 获取上次活跃日期
  static DateTime? get lastActiveDate {
    final dateStr = LocalStorageService.getSetting<String>(_lastActiveDateKey);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }
  
  static set lastActiveDate(DateTime? date) {
    if (date != null) {
      LocalStorageService.setSetting(_lastActiveDateKey, date.toIso8601String());
    }
  }
  
  /// 记录一次练习（打卡）
  static Future<StreakResult> recordPractice() async {
    final now = DateTime.now();
    final lastActive = lastActiveDate;
    
    // 今天已经打卡了
    if (hasPracticedToday) {
      return StreakResult(
        streak: currentStreak,
        isNewRecord: false,
        isStreakContinued: true,
        message: '今天已经打卡了，明天再来！',
      );
    }
    
    // 检查是否是连续打卡
    if (lastActive != null) {
      final difference = now.difference(lastActive).inDays;
      
      if (difference == 1) {
        // 连续打卡
        currentStreak++;
        
        // 更新最长记录
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        
        lastActiveDate = now;
        _addToHistory(now);
        
        HapticFeedback.heavyImpact();
        
        return StreakResult(
          streak: currentStreak,
          isNewRecord: currentStreak > longestStreak - 1,
          isStreakContinued: true,
          message: '连续打卡第 $currentStreak 天！🔥',
        );
      } else if (difference > 1) {
        // 断开了，检查是否有 streak freeze
        if (streakFreezeCount > 0) {
          // 使用 freeze
          streakFreezeCount--;
          _recordStreakFreezeUse();
          
          // 保持streak
          lastActiveDate = now;
          _addToHistory(now);
          
          HapticFeedback.mediumImpact();
          
          return StreakResult(
            streak: currentStreak,
            isNewRecord: false,
            isStreakContinued: true,
            message: '使用了 Streak Freeze！连续 $currentStreak 天继续保持',
            usedFreeze: true,
          );
        } else {
          // 真的断了，重置
          final oldStreak = currentStreak;
          currentStreak = 1;
          lastActiveDate = now;
          _addToHistory(now);
          
          HapticFeedback.vibrate();
          
          return StreakResult(
            streak: 1,
            isNewRecord: false,
            isStreakContinued: false,
            message: '连续 $oldStreak 天中断。新的开始！',
          );
        }
      }
    }
    
    // 第一次打卡
    currentStreak = 1;
    longestStreak = 1;
    lastActiveDate = now;
    _addToHistory(now);
    
    HapticFeedback.mediumImpact();
    
    return StreakResult(
      streak: 1,
      isNewRecord: false,
      isStreakContinued: true,
      message: '第一天打卡！开始你的健脑之旅',
    );
  }
  
  /// 购买 Streak Freeze
  static bool purchaseStreakFreeze(int neuronCoins) {
    const cost = 100; // 100 神经元币买一个 freeze
    
    if (neuronCoins >= cost) {
      streakFreezeCount++;
      return true;
    }
    return false;
  }
  
  /// 添加到历史记录
  static void _addToHistory(DateTime date) {
    final history = streakHistory;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    if (!history.contains(dateStr)) {
      history.add(dateStr);
      LocalStorageService.setSetting(_streakHistoryKey, history.join(','));
    }
  }
  
  /// 获取打卡历史
  static List<String> get streakHistory {
    final historyStr = LocalStorageService.getSetting<String>(_streakHistoryKey);
    if (historyStr == null || historyStr.isEmpty) return [];
    return historyStr.split(',');
  }
  
  /// 检查里程碑奖励
  static StreakMilestone? checkMilestone(int streak) {
    const milestones = {
      3: StreakMilestone(day: 3, reward: 50, title: '初出茅庐'),
      7: StreakMilestone(day: 7, reward: 100, title: '一周坚持'),
      14: StreakMilestone(day: 14, reward: 200, title: '两周强者'),
      21: StreakMilestone(day: 21, reward: 300, title: '习惯养成'),
      30: StreakMilestone(day: 30, reward: 500, title: '月度达人'),
      60: StreakMilestone(day: 60, reward: 1000, title: '健脑大师'),
      100: StreakMilestone(day: 100, reward: 2000, title: '百日神话'),
      365: StreakMilestone(day: 365, reward: 10000, title: '年度传奇'),
    };
    
    return milestones[streak];
  }
  
  /// 获取本周打卡天数
  static int getWeeklyStreak() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final history = streakHistory;
    
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (history.contains(dateStr)) {
        count++;
      }
    }
    return count;
  }
  
  static void _recordStreakFreezeUse() {
    final now = DateTime.now();
    LocalStorageService.setSetting(_lastStreakFreezeDateKey, now.toIso8601String());
  }
  
  /// 重置所有数据（测试用）
  static void reset() {
    currentStreak = 0;
    longestStreak = 0;
    streakFreezeCount = 0;
    lastActiveDate = null;
    LocalStorageService.setSetting(_streakHistoryKey, '');
  }
}

/// 打卡结果
class StreakResult {
  final int streak;
  final bool isNewRecord;
  final bool isStreakContinued;
  final String message;
  final bool usedFreeze;
  final StreakMilestone? milestone;
  
  StreakResult({
    required this.streak,
    required this.isNewRecord,
    required this.isStreakContinued,
    required this.message,
    this.usedFreeze = false,
    this.milestone,
  });
}

/// 里程碑奖励
class StreakMilestone {
  final int day;
  final int reward;
  final String title;
  
  const StreakMilestone({
    required this.day,
    required this.reward,
    required this.title,
  });
}

/// 连续打卡天数状态
enum StreakStatus {
  notStarted,      // 还未开始
  active,          // 进行中
  atRisk,          // 有风险（今天还没打卡）
  frozen,          // 使用了 freeze
  broken,          // 已中断
}
