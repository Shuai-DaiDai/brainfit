import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// 本地用户模型
class LocalUser {
  final String uid;
  final String? email;
  final String displayName;
  final int brainAge;
  final int chronologicalAge;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocalUser({
    required this.uid,
    this.email,
    required this.displayName,
    this.brainAge = 28,
    this.chronologicalAge = 28,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocalUser.anonymous() {
    return LocalUser(
      uid: const Uuid().v4(),
      displayName: '脑力运动员',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'brainAge': brainAge,
    'chronologicalAge': chronologicalAge,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
    uid: json['uid'],
    email: json['email'],
    displayName: json['displayName'],
    brainAge: json['brainAge'] ?? 28,
    chronologicalAge: json['chronologicalAge'] ?? 28,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  LocalUser copyWith({
    String? displayName,
    int? brainAge,
    int? chronologicalAge,
  }) => LocalUser(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    brainAge: brainAge ?? this.brainAge,
    chronologicalAge: chronologicalAge ?? this.chronologicalAge,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}

/// 练习记录模型
class PracticeSession {
  final String id;
  final String type;
  final int duration; // 秒
  final int? score;
  final Map<String, dynamic> metadata;
  final DateTime completedAt;

  PracticeSession({
    required this.id,
    required this.type,
    required this.duration,
    this.score,
    this.metadata = const {},
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'duration': duration,
    'score': score,
    'metadata': metadata,
    'completedAt': completedAt.toIso8601String(),
  };

  factory PracticeSession.fromJson(Map<String, dynamic> json) => PracticeSession(
    id: json['id'],
    type: json['type'],
    duration: json['duration'],
    score: json['score'],
    metadata: json['metadata'] ?? {},
    completedAt: DateTime.parse(json['completedAt']),
  );
}

/// 连续打卡数据
class StreakData {
  int currentStreak;
  int longestStreak;
  int totalCheckIns;
  DateTime? lastCheckIn;

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCheckIns = 0,
    this.lastCheckIn,
  });

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalCheckIns': totalCheckIns,
    'lastCheckIn': lastCheckIn?.toIso8601String(),
  };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    totalCheckIns: json['totalCheckIns'] ?? 0,
    lastCheckIn: json['lastCheckIn'] != null 
      ? DateTime.parse(json['lastCheckIn']) 
      : null,
  );
}

/// 奖励数据
class RewardsData {
  int balance;
  int totalEarned;
  int totalSpent;

  RewardsData({
    this.balance = 100, // 初始赠送
    this.totalEarned = 100,
    this.totalSpent = 0,
  });

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'totalEarned': totalEarned,
    'totalSpent': totalSpent,
  };

  factory RewardsData.fromJson(Map<String, dynamic> json) => RewardsData(
    balance: json['balance'] ?? 100,
    totalEarned: json['totalEarned'] ?? 100,
    totalSpent: json['totalSpent'] ?? 0,
  );
}

/// 成就模型
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int reward;
  bool unlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.reward = 50,
    this.unlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'reward': reward,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: json['icon'],
    reward: json['reward'] ?? 50,
    unlocked: json['unlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null 
      ? DateTime.parse(json['unlockedAt']) 
      : null,
  );
}

/// 默认成就列表
List<Achievement> getDefaultAchievements() {
  return [
    Achievement(
      id: 'first_practice',
      name: '初次体验',
      description: '完成第一次练习',
      icon: '🎯',
      reward: 50,
    ),
    Achievement(
      id: 'three_day_streak',
      name: '三连击',
      description: '连续打卡3天',
      icon: '🔥',
      reward: 100,
    ),
    Achievement(
      id: 'seven_day_streak',
      name: '一周坚持',
      description: '连续打卡7天',
      icon: '📅',
      reward: 200,
    ),
    Achievement(
      id: 'thirty_day_streak',
      name: '月度达人',
      description: '连续打卡30天',
      icon: '🏆',
      reward: 500,
    ),
    Achievement(
      id: 'brain_age_test',
      name: '了解自己',
      description: '完成脑力年龄测试',
      icon: '🧠',
      reward: 100,
    ),
    Achievement(
      id: 'breathing_master',
      name: '呼吸大师',
      description: '完成10次呼吸练习',
      icon: '🫁',
      reward: 100,
    ),
    Achievement(
      id: 'meditation_master',
      name: '冥想入门',
      description: '完成5次正念冥想',
      icon: '🧘',
      reward: 150,
    ),
    Achievement(
      id: 'n_back_novice',
      name: '记忆新手',
      description: 'Dual N-back达到Level 3',
      icon: '🎮',
      reward: 200,
    ),
    Achievement(
      id: 'n_back_expert',
      name: '记忆专家',
      description: 'Dual N-back达到Level 6',
      icon: '👑',
      reward: 500,
    ),
    Achievement(
      id: 'rich',
      name: '小富翁',
      description: '累计获得1000神经元币',
      icon: '💰',
      reward: 100,
    ),
    Achievement(
      id: 'collector',
      name: '成就收藏家',
      description: '解锁5个成就',
      icon: '🏅',
      reward: 200,
    ),
    Achievement(
      id: 'master',
      name: '脑力大师',
      description: '解锁所有成就',
      icon: '🎓',
      reward: 1000,
    ),
  ];
}

/// 本地存储服务 - 完全替代 Firebase
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Box<String> _userBox;
  late Box<String> _sessionsBox;
  late Box<String> _streakBox;
  late Box<String> _rewardsBox;
  late Box<String> _achievementsBox;
  late Box<String> _settingsBox;

  bool _initialized = false;

  /// 初始化
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _userBox = await Hive.openBox<String>('user');
    _sessionsBox = await Hive.openBox<String>('sessions');
    _streakBox = await Hive.openBox<String>('streak');
    _rewardsBox = await Hive.openBox<String>('rewards');
    _achievementsBox = await Hive.openBox<String>('achievements');
    _settingsBox = await Hive.openBox<String>('settings');

    // 初始化默认数据
    await _initDefaultData();

    _initialized = true;
  }

  /// 初始化默认数据
  Future<void> _initDefaultData() async {
    // 用户
    if (_userBox.get('current') == null) {
      final user = LocalUser.anonymous();
      await _userBox.put('current', jsonEncode(user.toJson()));
    }

    // Streak
    if (_streakBox.get('data') == null) {
      final streak = StreakData();
      await _streakBox.put('data', jsonEncode(streak.toJson()));
    }

    // 奖励
    if (_rewardsBox.get('data') == null) {
      final rewards = RewardsData();
      await _rewardsBox.put('data', jsonEncode(rewards.toJson()));
    }

    // 成就
    if (_achievementsBox.get('list') == null) {
      final achievements = getDefaultAchievements();
      await _achievementsBox.put(
        'list', 
        jsonEncode(achievements.map((a) => a.toJson()).toList()),
      );
    }
  }

  // ========== 用户管理 ==========

  LocalUser? getCurrentUser() {
    final data = _userBox.get('current');
    if (data == null) return null;
    return LocalUser.fromJson(jsonDecode(data));
  }

  Future<void> saveUser(LocalUser user) async {
    await _userBox.put('current', jsonEncode(user.toJson()));
  }

  Future<void> updateUser({
    String? displayName,
    int? brainAge,
    int? chronologicalAge,
  }) async {
    final current = getCurrentUser();
    if (current == null) return;
    
    final updated = current.copyWith(
      displayName: displayName,
      brainAge: brainAge,
      chronologicalAge: chronologicalAge,
    );
    await saveUser(updated);
  }

  // ========== 练习记录 ==========

  Future<void> savePracticeSession({
    required String type,
    required int duration,
    int? score,
    Map<String, dynamic>? metadata,
  }) async {
    final session = PracticeSession(
      id: const Uuid().v4(),
      type: type,
      duration: duration,
      score: score,
      metadata: metadata ?? {},
      completedAt: DateTime.now(),
    );

    final sessions = getPracticeSessions();
    sessions.insert(0, session);
    
    // 只保留最近 100 条
    while (sessions.length > 100) {
      sessions.removeLast();
    }

    await _sessionsBox.put(
      'list',
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );

    // 更新 Streak
    await _updateStreak();

    // 检查成就
    await _checkPracticeAchievements(type);
  }

  List<PracticeSession> getPracticeSessions() {
    final data = _sessionsBox.get('list');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => PracticeSession.fromJson(e)).toList();
  }

  List<PracticeSession> getRecentSessions({int limit = 50}) {
    return getPracticeSessions().take(limit).toList();
  }

  // ========== Streak 系统 ==========

  StreakData getStreakData() {
    final data = _streakBox.get('data');
    if (data == null) return StreakData();
    return StreakData.fromJson(jsonDecode(data));
  }

  Future<void> _updateStreak() async {
    final streak = getStreakData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (streak.lastCheckIn == null) {
      // 第一次打卡
      streak.currentStreak = 1;
      streak.longestStreak = 1;
      streak.totalCheckIns = 1;
      streak.lastCheckIn = today;
    } else {
      final lastDate = DateTime(
        streak.lastCheckIn!.year,
        streak.lastCheckIn!.month,
        streak.lastCheckIn!.day,
      );
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // 今天已经打卡，不更新
        return;
      } else if (diff == 1) {
        // 连续打卡
        streak.currentStreak++;
        streak.totalCheckIns++;
        if (streak.currentStreak > streak.longestStreak) {
          streak.longestStreak = streak.currentStreak;
        }
        streak.lastCheckIn = today;
      } else {
        // 断签，重新计算
        streak.currentStreak = 1;
        streak.totalCheckIns++;
        streak.lastCheckIn = today;
      }
    }

    await _streakBox.put('data', jsonEncode(streak.toJson()));

    // 检查 Streak 成就
    await _checkStreakAchievements(streak);
  }

  // ========== 奖励系统 ==========

  RewardsData getRewardsData() {
    final data = _rewardsBox.get('data');
    if (data == null) return RewardsData();
    return RewardsData.fromJson(jsonDecode(data));
  }

  Future<void> addBalance(int amount, {String? reason}) async {
    final rewards = getRewardsData();
    rewards.balance += amount;
    rewards.totalEarned += amount;
    await _rewardsBox.put('data', jsonEncode(rewards.toJson()));
  }

  Future<void> spendBalance(int amount, {String? reason}) async {
    final rewards = getRewardsData();
    if (rewards.balance >= amount) {
      rewards.balance -= amount;
      rewards.totalSpent += amount;
      await _rewardsBox.put('data', jsonEncode(rewards.toJson()));
    }
  }

  Future<bool> canAfford(int amount) async {
    final rewards = getRewardsData();
    return rewards.balance >= amount;
  }

  // ========== 成就系统 ==========

  List<Achievement> getAchievements() {
    final data = _achievementsBox.get('list');
    if (data == null) return getDefaultAchievements();
    final list = jsonDecode(data) as List;
    return list.map((e) => Achievement.fromJson(e)).toList();
  }

  Future<void> unlockAchievement(String id) async {
    final achievements = getAchievements();
    final index = achievements.indexWhere((a) => a.id == id);
    
    if (index != -1 && !achievements[index].unlocked) {
      achievements[index].unlocked = true;
      achievements[index].unlockedAt = DateTime.now();
      
      await _achievementsBox.put(
        'list',
        jsonEncode(achievements.map((a) => a.toJson()).toList()),
      );

      // 发放奖励
      await addBalance(achievements[index].reward, reason: 'achievement_$id');
    }
  }

  bool isAchievementUnlocked(String id) {
    final achievements = getAchievements();
    final achievement = achievements.firstWhere(
      (a) => a.id == id,
      orElse: () => Achievement(id: '', name: '', description: '', icon: ''),
    );
    return achievement.unlocked;
  }

  Future<void> _checkPracticeAchievements(String type) async {
    final sessions = getPracticeSessions();
    
    // 首次练习
    if (sessions.length == 1) {
      await unlockAchievement('first_practice');
    }

    // 呼吸大师
    if (type.contains('breathing')) {
      final breathingCount = sessions.where((s) => s.type.contains('breathing')).length;
      if (breathingCount >= 10) {
        await unlockAchievement('breathing_master');
      }
    }

    // 冥想入门
    if (type.contains('meditation')) {
      final meditationCount = sessions.where((s) => s.type.contains('meditation')).length;
      if (meditationCount >= 5) {
        await unlockAchievement('meditation_master');
      }
    }

    // 小富翁
    final rewards = getRewardsData();
    if (rewards.totalEarned >= 1000) {
      await unlockAchievement('rich');
    }

    // 成就收藏家
    final unlockedCount = getAchievements().where((a) => a.unlocked).length;
    if (unlockedCount >= 5) {
      await unlockAchievement('collector');
    }
    if (unlockedCount >= getDefaultAchievements().length - 1) {
      await unlockAchievement('master');
    }
  }

  Future<void> _checkStreakAchievements(StreakData streak) async {
    if (streak.currentStreak >= 3) {
      await unlockAchievement('three_day_streak');
    }
    if (streak.currentStreak >= 7) {
      await unlockAchievement('seven_day_streak');
    }
    if (streak.currentStreak >= 30) {
      await unlockAchievement('thirty_day_streak');
    }
  }

  // ========== 统计数据 ==========

  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final sessions = getPracticeSessions().where((s) {
      return s.completedAt.isAfter(weekAgo);
    }).toList();
    
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + (s.duration ~/ 60),
    );
    
    final typeCount = <String, int>{};
    for (final session in sessions) {
      typeCount[session.type] = (typeCount[session.type] ?? 0) + 1;
    }
    
    return {
      'totalSessions': sessions.length,
      'totalMinutes': totalMinutes,
      'dailyAverage': sessions.isEmpty ? 0 : totalMinutes / 7,
      'typeDistribution': typeCount,
    };
  }

  Map<String, dynamic> getMonthlyStats() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    
    final sessions = getPracticeSessions().where((s) {
      return s.completedAt.isAfter(monthAgo);
    }).toList();
    
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + (s.duration ~/ 60),
    );
    
    return {
      'totalSessions': sessions.length,
      'totalMinutes': totalMinutes,
      'dailyAverage': sessions.isEmpty ? 0 : totalMinutes / 30,
    };
  }

  // ========== 设置 ==========

  T? getSetting<T>(String key, {T? defaultValue}) {
    final data = _settingsBox.get(key);
    if (data == null) return defaultValue;
    
    if (T == bool) return (data == 'true') as T;
    if (T == int) return int.tryParse(data) as T? ?? defaultValue;
    if (T == double) return double.tryParse(data) as T? ?? defaultValue;
    return data as T? ?? defaultValue;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value.toString());
  }

  // 便捷属性
  bool get hasCompletedOnboarding => 
      getSetting<bool>('has_completed_onboarding', defaultValue: false) ?? false;
  
  set hasCompletedOnboarding(bool value) => 
      setSetting('has_completed_onboarding', value);

  bool get hasTakenBrainAgeTest => 
      getSetting<bool>('has_taken_brain_age_test', defaultValue: false) ?? false;
  
  set hasTakenBrainAgeTest(bool value) => 
      setSetting('has_taken_brain_age_test', value);

  // ========== 数据重置 ==========

  Future<void> resetAllData() async {
    await _userBox.clear();
    await _sessionsBox.clear();
    await _streakBox.clear();
    await _rewardsBox.clear();
    await _achievementsBox.clear();
    await _settingsBox.clear();
    
    await _initDefaultData();
  }

  Future<void> clearAll() async {
    await resetAllData();
  }
}
