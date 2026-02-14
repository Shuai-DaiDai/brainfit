import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/services/local_storage_service.dart';

/// 奖励系统 - 神经元币管理
class RewardService {
  static const String _coinsKey = 'neuron_coins';
  static const String _totalEarnedKey = 'total_coins_earned';
  static const String _transactionsKey = 'coin_transactions';
  static const String _lastDailyRewardKey = 'last_daily_reward';
  
  /// 获取当前神经元币余额
  static int get balance {
    return LocalStorageService.getSetting<int>(_coinsKey, defaultValue: 0) ?? 0;
  }
  
  static set _balance(int value) {
    LocalStorageService.setSetting(_coinsKey, value);
  }
  
  /// 获取总共赚取的神经元币
  static int get totalEarned {
    return LocalStorageService.getSetting<int>(_totalEarnedKey, defaultValue: 0) ?? 0;
  }
  
  static set _totalEarned(int value) {
    LocalStorageService.setSetting(_totalEarnedKey, value);
  }
  
  /// 赚取神经元币
  static Future<RewardResult> earnCoins({
    required int amount,
    required RewardType type,
    String? description,
  }) async {
    // 触觉反馈
    if (amount > 0) {
      HapticFeedback.mediumImpact();
    }
    
    // 更新余额
    _balance += amount;
    _totalEarned += amount;
    
    // 记录交易
    final transaction = CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: type,
      description: description ?? type.defaultDescription,
      timestamp: DateTime.now(),
    );
    
    _addTransaction(transaction);
    
    return RewardResult(
      success: true,
      amount: amount,
      newBalance: _balance,
      type: type,
      message: '+$amount 神经元币！',
    );
  }
  
  /// 消费神经元币
  static Future<RewardResult> spendCoins({
    required int amount,
    required String description,
  }) async {
    if (_balance < amount) {
      return RewardResult(
        success: false,
        amount: 0,
        newBalance: _balance,
        type: RewardType.purchase,
        message: '余额不足',
      );
    }
    
    _balance -= amount;
    
    final transaction = CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: -amount,
      type: RewardType.purchase,
      description: description,
      timestamp: DateTime.now(),
    );
    
    _addTransaction(transaction);
    
    return RewardResult(
      success: true,
      amount: -amount,
      newBalance: _balance,
      type: RewardType.purchase,
      message: '-$amount 神经元币',
    );
  }
  
  /// 添加交易记录
  static void _addTransaction(CoinTransaction transaction) {
    final transactions = transactionHistory;
    transactions.insert(0, transaction);
    
    // 只保留最近100条记录
    if (transactions.length > 100) {
      transactions.removeRange(100, transactions.length);
    }
    
    // 序列化并保存
    final jsonList = transactions.map((t) => t.toJson()).join('|||');
    LocalStorageService.setSetting(_transactionsKey, jsonList);
  }
  
  /// 获取交易历史
  static List<CoinTransaction> get transactionHistory {
    final jsonStr = LocalStorageService.getSetting<String>(_transactionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    
    return jsonStr.split('|||').map((json) {
      try {
        return CoinTransaction.fromJson(json);
      } catch (e) {
        return null;
      }
    }).where((t) => t != null).cast<CoinTransaction>().toList();
  }
  
  /// 检查今日签到奖励
  static bool get canClaimDailyReward {
    final lastClaim = LocalStorageService.getSetting<String>(_lastDailyRewardKey);
    if (lastClaim == null) return true;
    
    final lastDate = DateTime.parse(lastClaim);
    final now = DateTime.now();
    
    return lastDate.year != now.year ||
           lastDate.month != now.month ||
           lastDate.day != now.day;
  }
  
  /// 领取每日签到奖励
  static Future<RewardResult> claimDailyReward() async {
    if (!canClaimDailyReward) {
      return RewardResult(
        success: false,
        amount: 0,
        newBalance: balance,
        type: RewardType.dailyReward,
        message: '今日已领取',
      );
    }
    
    // 连续签到奖励递增
    final streak = _getDailyStreak();
    int baseReward = 50;
    int bonus = (streak * 10).clamp(0, 100);
    int totalReward = baseReward + bonus;
    
    LocalStorageService.setSetting(
      _lastDailyRewardKey,
      DateTime.now().toIso8601String(),
    );
    
    return earnCoins(
      amount: totalReward,
      type: RewardType.dailyReward,
      description: '每日签到奖励（连续$streak天）',
    );
  }
  
  /// 获取连续签到天数
  static int _getDailyStreak() {
    // 简化实现：从交易记录中计算
    final transactions = transactionHistory
        .where((t) => t.type == RewardType.dailyReward)
        .toList();
    
    if (transactions.isEmpty) return 0;
    
    int streak = 1;
    DateTime lastDate = transactions.first.timestamp;
    
    for (int i = 1; i < transactions.length && i < 7; i++) {
      final diff = lastDate.difference(transactions[i].timestamp).inDays;
      if (diff == 1) {
        streak++;
        lastDate = transactions[i].timestamp;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  /// 购买 Streak Freeze
  static Future<RewardResult> purchaseStreakFreeze() async {
    const cost = 100;
    
    final result = await spendCoins(
      amount: cost,
      description: '购买 Streak Freeze',
    );
    
    if (result.success) {
      // 这里应该调用 StreakService 增加 freeze 数量
      // 简化实现，实际需要 StreakService 配合
    }
    
    return result;
  }
  
  /// 获取今日收入
  static int getTodayEarnings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return transactionHistory
        .where((t) => t.amount > 0 && t.timestamp.isAfter(today))
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  /// 获取本周收入
  static int getWeekEarnings() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return transactionHistory
        .where((t) => t.amount > 0 && t.timestamp.isAfter(weekStartDate))
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  /// 重置所有数据（测试用）
  static void reset() {
    _balance = 0;
    _totalEarned = 0;
    LocalStorageService.setSetting(_transactionsKey, '');
    LocalStorageService.setSetting(_lastDailyRewardKey, '');
  }
}

/// 奖励类型
enum RewardType {
  practiceComplete,    // 完成练习
  streakMilestone,     // 连续打卡里程碑
  dailyReward,         // 每日签到
  brainAgeTest,        // 完成脑力测试
  achievement,         // 成就解锁
  purchase,            // 消费
  referral,            // 邀请好友
  bonus,               // 额外奖励
}

extension RewardTypeExtension on RewardType {
  String get defaultDescription {
    switch (this) {
      case RewardType.practiceComplete:
        return '完成练习';
      case RewardType.streakMilestone:
        return '连续打卡奖励';
      case RewardType.dailyReward:
        return '每日签到';
      case RewardType.brainAgeTest:
        return '完成脑力测试';
      case RewardType.achievement:
        return '成就解锁';
      case RewardType.purchase:
        return '消费';
      case RewardType.referral:
        return '邀请好友';
      case RewardType.bonus:
        return '额外奖励';
    }
  }
  
  IconData get icon {
    switch (this) {
      case RewardType.practiceComplete:
        return Icons.self_improvement;
      case RewardType.streakMilestone:
        return Icons.local_fire_department;
      case RewardType.dailyReward:
        return Icons.card_giftcard;
      case RewardType.brainAgeTest:
        return Icons.psychology;
      case RewardType.achievement:
        return Icons.emoji_events;
      case RewardType.purchase:
        return Icons.shopping_cart;
      case RewardType.referral:
        return Icons.people;
      case RewardType.bonus:
        return Icons.stars;
    }
  }
}

/// 交易记录
class CoinTransaction {
  final String id;
  final int amount;
  final RewardType type;
  final String description;
  final DateTime timestamp;
  
  CoinTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });
  
  String toJson() {
    return '$id|${amount}|${type.name}|$description|${timestamp.toIso8601String()}';
  }
  
  factory CoinTransaction.fromJson(String json) {
    final parts = json.split('|');
    return CoinTransaction(
      id: parts[0],
      amount: int.parse(parts[1]),
      type: RewardType.values.firstWhere((e) => e.name == parts[2]),
      description: parts[3],
      timestamp: DateTime.parse(parts[4]),
    );
  }
  
  String get formattedTime {
    return DateFormat('MM-dd HH:mm').format(timestamp);
  }
  
  bool get isIncome => amount > 0;
}

/// 奖励结果
class RewardResult {
  final bool success;
  final int amount;
  final int newBalance;
  final RewardType type;
  final String message;
  
  RewardResult({
    required this.success,
    required this.amount,
    required this.newBalance,
    required this.type,
    required this.message,
  });
}

/// 奖励配置
class RewardConfig {
  // 基础奖励
  static const int basePracticeReward = 10;           // 基础练习奖励
  static const int resonantBreathingBonus = 5;        // 共振呼吸额外奖励
  static const int cyclicSighingBonus = 5;            // 循环叹息额外奖励
  static const int brainAgeTestBonus = 50;            // 完成脑力测试
  
  // 连续打卡里程碑奖励
  static const Map<int, int> streakMilestones = {
    3: 50,
    7: 100,
    14: 200,
    21: 300,
    30: 500,
    60: 1000,
    100: 2000,
  };
  
  // 成就奖励
  static const Map<String, int> achievementRewards = {
    'first_practice': 20,       // 第一次练习
    'first_week': 100,          // 坚持一周
    'attention_master': 200,    // 注意力测试优秀
    'memory_master': 200,       // 记忆测试优秀
    'speed_master': 200,        // 反应速度优秀
    'brain_age_improved': 500,  // 脑力年龄改善
  };
  
  // 计算练习奖励
  static int calculatePracticeReward({
    required int durationSeconds,
    required String practiceType,
    bool isCompleted = true,
  }) {
    if (!isCompleted) return 0;
    
    // 基础奖励：每分钟10币
    int reward = (durationSeconds ~/ 60) * basePracticeReward;
    
    // 完成奖励
    reward += 10;
    
    // 类型额外奖励
    switch (practiceType) {
      case 'resonant':
        reward += resonantBreathingBonus;
        break;
      case 'cyclic_sighing':
        reward += cyclicSighingBonus;
        break;
    }
    
    // 随机额外奖励 (0-20)
    reward += (DateTime.now().millisecond % 21);
    
    return reward;
  }
}
