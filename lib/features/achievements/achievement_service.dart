import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../features/rewards/reward_service.dart';

/// 成就系统
class AchievementService {
  static const String _achievementsKey = 'unlocked_achievements';
  
  /// 所有成就定义
  static final List<Achievement> allAchievements = [
    Achievement(
      id: 'first_practice',
      title: '初次体验',
      description: '完成第一次健脑练习',
      icon: '🌱',
      reward: 20,
      category: AchievementCategory.beginner,
    ),
    Achievement(
      id: 'first_week',
      title: '一周坚持',
      description: '连续打卡7天',
      icon: '🔥',
      reward: 100,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'first_month',
      title: '月度达人',
      description: '连续打卡30天',
      icon: '📅',
      reward: 500,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'attention_master',
      title: '注意力大师',
      description: '注意力测试达到90分以上',
      icon: '👁️',
      reward: 200,
      category: AchievementCategory.skill,
    ),
    Achievement(
      id: 'memory_master',
      title: '记忆大师',
      description: '工作记忆测试达到90分以上',
      icon: '🧩',
      reward: 200,
      category: AchievementCategory.skill,
    ),
    Achievement(
      id: 'speed_master',
      title: '反应神速',
      description: '反应速度测试达到90分以上',
      icon: '⚡',
      reward: 200,
      category: AchievementCategory.skill,
    ),
    Achievement(
      id: 'brain_age_improved',
      title: '脑力回春',
      description: '脑力年龄比首次测试年轻3岁以上',
      icon: '🧠',
      reward: 500,
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'hundred_coins',
      title: '初露锋芒',
      description: '累计赚取100神经元币',
      icon: '💰',
      reward: 50,
      category: AchievementCategory.wealth,
    ),
    Achievement(
      id: 'thousand_coins',
      title: '财富自由',
      description: '累计赚取1000神经元币',
      icon: '💎',
      reward: 200,
      category: AchievementCategory.wealth,
    ),
    Achievement(
      id: 'breathing_expert',
      title: '呼吸专家',
      description: '完成50次呼吸练习',
      icon: '🫁',
      reward: 150,
      category: AchievementCategory.practice,
    ),
    Achievement(
      id: 'early_bird',
      title: '早起鸟儿',
      description: '早上8点前完成练习',
      icon: '🌅',
      reward: 30,
      category: AchievementCategory.special,
    ),
    Achievement(
      id: 'night_owl',
      title: '夜猫子',
      description: '晚上10点后完成练习',
      icon: '🌙',
      reward: 30,
      category: AchievementCategory.special,
    ),
  ];
  
  /// 获取已解锁的成就
  static List<String> get unlockedAchievements {
    final saved = LocalStorageService.getSetting<String>(_achievementsKey);
    if (saved == null || saved.isEmpty) return [];
    return saved.split(',');
  }
  
  static set _unlockedAchievements(List<String> value) {
    LocalStorageService.setSetting(_achievementsKey, value.join(','));
  }
  
  /// 检查成就是否已解锁
  static bool isUnlocked(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }
  
  /// 解锁成就
  static Future<Achievement?> unlock(String achievementId) async {
    if (isUnlocked(achievementId)) return null;
    
    final achievement = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );
    
    // 添加到已解锁列表
    final unlocked = unlockedAchievements;
    unlocked.add(achievementId);
    _unlockedAchievements = unlocked;
    
    // 发放奖励
    await RewardService.earnCoins(
      amount: achievement.reward,
      type: RewardType.achievement,
      description: '解锁成就：${achievement.title}',
    );
    
    // 触觉反馈
    HapticFeedback.heavyImpact();
    
    return achievement;
  }
  
  /// 检查并自动解锁成就
  static Future<List<Achievement>> checkAndUnlock() async {
    final unlocked = <Achievement>[];
    
    // 检查各个成就条件
    // 这里简化实现，实际需要根据用户数据统计
    
    // 初次体验
    if (!isUnlocked('first_practice')) {
      final practiceCount = LocalStorageService.getSetting<int>('total_practices', defaultValue: 0) ?? 0;
      if (practiceCount > 0) {
        final achievement = await unlock('first_practice');
        if (achievement != null) unlocked.add(achievement);
      }
    }
    
    // 一周坚持
    if (!isUnlocked('first_week')) {
      final streak = LocalStorageService.getSetting<int>('current_streak', defaultValue: 0) ?? 0;
      if (streak >= 7) {
        final achievement = await unlock('first_week');
        if (achievement != null) unlocked.add(achievement);
      }
    }
    
    // 月度达人
    if (!isUnlocked('first_month')) {
      final streak = LocalStorageService.getSetting<int>('current_streak', defaultValue: 0) ?? 0;
      if (streak >= 30) {
        final achievement = await unlock('first_month');
        if (achievement != null) unlocked.add(achievement);
      }
    }
    
    // 财富类成就
    if (!isUnlocked('hundred_coins')) {
      if (RewardService.totalEarned >= 100) {
        final achievement = await unlock('hundred_coins');
        if (achievement != null) unlocked.add(achievement);
      }
    }
    
    if (!isUnlocked('thousand_coins')) {
      if (RewardService.totalEarned >= 1000) {
        final achievement = await unlock('thousand_coins');
        if (achievement != null) unlocked.add(achievement);
      }
    }
    
    return unlocked;
  }
  
  /// 获取成就进度
  static double getProgress(String achievementId) {
    // 简化实现，返回0-1之间的进度
    switch (achievementId) {
      case 'first_practice':
        final count = LocalStorageService.getSetting<int>('total_practices', defaultValue: 0) ?? 0;
        return count > 0 ? 1.0 : 0.0;
      case 'first_week':
        final streak = LocalStorageService.getSetting<int>('current_streak', defaultValue: 0) ?? 0;
        return (streak / 7).clamp(0.0, 1.0);
      case 'first_month':
        final streak = LocalStorageService.getSetting<int>('current_streak', defaultValue: 0) ?? 0;
        return (streak / 30).clamp(0.0, 1.0);
      case 'hundred_coins':
        return (RewardService.totalEarned / 100).clamp(0.0, 1.0);
      case 'thousand_coins':
        return (RewardService.totalEarned / 1000).clamp(0.0, 1.0);
      default:
        return isUnlocked(achievementId) ? 1.0 : 0.0;
    }
  }
  
  /// 获取分类的成就
  static List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }
  
  /// 获取统计
  static AchievementStats getStats() {
    final total = allAchievements.length;
    final unlocked = unlockedAchievements.length;
    
    return AchievementStats(
      total: total,
      unlocked: unlocked,
      progress: unlocked / total,
      totalRewards: allAchievements
          .where((a) => isUnlocked(a.id))
          .fold(0, (sum, a) => sum + a.reward),
    );
  }
  
  /// 重置所有成就（测试用）
  static void reset() {
    _unlockedAchievements = [];
  }
}

/// 成就数据类
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int reward;
  final AchievementCategory category;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.reward,
    required this.category,
  });
  
  bool get isUnlocked => AchievementService.isUnlocked(id);
  
  double get progress => AchievementService.getProgress(id);
}

/// 成就分类
enum AchievementCategory {
  beginner,    // 新手
  streak,      // 连续打卡
  skill,       // 技能
  milestone,   // 里程碑
  wealth,      // 财富
  practice,    // 练习
  special,     // 特殊
}

extension AchievementCategoryExtension on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.beginner:
        return '新手入门';
      case AchievementCategory.streak:
        return '连续打卡';
      case AchievementCategory.skill:
        return '技能大师';
      case AchievementCategory.milestone:
        return '里程碑';
      case AchievementCategory.wealth:
        return '财富积累';
      case AchievementCategory.practice:
        return '练习达人';
      case AchievementCategory.special:
        return '特殊成就';
    }
  }
  
  Color get color {
    switch (this) {
      case AchievementCategory.beginner:
        return const Color(0xFF4ECDC4);
      case AchievementCategory.streak:
        return const Color(0xFFFF6B35);
      case AchievementCategory.skill:
        return const Color(0xFF667EEA);
      case AchievementCategory.milestone:
        return const Color(0xFFF4A261);
      case AchievementCategory.wealth:
        return const Color(0xFFFFD93D);
      case AchievementCategory.practice:
        return const Color(0xFF6BCB77);
      case AchievementCategory.special:
        return const Color(0xFFFF6B9D);
    }
  }
}

/// 成就统计
class AchievementStats {
  final int total;
  final int unlocked;
  final double progress;
  final int totalRewards;
  
  AchievementStats({
    required this.total,
    required this.unlocked,
    required this.progress,
    required this.totalRewards,
  });
}
