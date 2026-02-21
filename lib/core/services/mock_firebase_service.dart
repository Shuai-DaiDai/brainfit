import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

/// 模拟用户
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  
  MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

/// Mock Firebase 服务 - 本地测试版本
/// 所有数据存储在本地内存和 Hive 中，无需网络连接
class MockFirebaseService {
  static MockUser? _currentUser;
  static final List<Map<String, dynamic>> _practiceSessions = [];
  static final Map<String, dynamic> _userData = {};
  static final Map<String, dynamic> _streakData = {};
  static final Map<String, dynamic> _rewardsData = {};
  static final Map<String, bool> _achievements = {};
  
  // 模拟用户ID生成
  static final _random = Random();
  
  // Stream 控制器
  static final _userDataController = StreamController<Map<String, dynamic>?>.broadcast();
  static final _streakController = StreamController<Map<String, dynamic>>.broadcast();
  static final _rewardsController = StreamController<Map<String, dynamic>>.broadcast();
  
  static Stream<Map<String, dynamic>?> get userDataStream => _userDataController.stream;
  static Stream<Map<String, dynamic>> get streakStream => _streakController.stream;
  static Stream<Map<String, dynamic>> get rewardsStream => _rewardsController.stream;

  /// 初始化
  static Future<void> initialize() async {
    if (kDebugMode) {
      print('🧠 BrainFit 本地模式启动');
      print('✅ 所有数据存储在本地，无需网络连接');
    }
    
    // 尝试从本地存储恢复用户
    await _loadFromLocal();
    
    // 如果没有用户，自动创建匿名用户
    if (_currentUser == null) {
      await signInAnonymously();
    }
  }

  /// 从本地存储加载数据
  static Future<void> _loadFromLocal() async {
    try {
      // 从 LocalStorageService 加载数据
      // 这里简化处理，实际应该使用 Hive 存储
    } catch (e) {
      if (kDebugMode) print('加载本地数据失败: $e');
    }
  }

  // ========== 用户认证 ==========
  
  static MockUser? get currentUser => _currentUser;
  static String? get userId => _currentUser?.uid;
  static bool get isAuthenticated => _currentUser != null;

  /// 匿名登录（自动创建本地用户）
  static Future<MockUser?> signInAnonymously() async {
    final uid = 'local_user_${_random.nextInt(1000000)}';
    _currentUser = MockUser(
      uid: uid,
      email: null,
      displayName: '脑力运动员',
    );
    
    // 初始化用户数据
    await _createUserDocument();
    
    if (kDebugMode) {
      print('✅ 本地用户创建成功: $uid');
    }
    
    return _currentUser;
  }

  /// 邮箱密码注册（本地模拟）
  static Future<MockUser?> signUpWithEmail(String email, String password) async {
    final uid = 'local_user_${_random.nextInt(1000000)}';
    _currentUser = MockUser(
      uid: uid,
      email: email,
      displayName: '脑力运动员',
    );
    
    await _createUserDocument();
    return _currentUser;
  }

  /// 邮箱密码登录（本地模拟）
  static Future<MockUser?> signInWithEmail(String email, String password) async {
    // 本地模式下，直接创建新用户
    return signUpWithEmail(email, password);
  }

  /// 退出登录
  static Future<void> signOut() async {
    _currentUser = null;
    _practiceSessions.clear();
    _userData.clear();
    _streakData.clear();
    _rewardsData.clear();
    _achievements.clear();
  }

  /// 创建用户文档
  static Future<void> _createUserDocument() async {
    _userData.addAll({
      'email': _currentUser?.email ?? '',
      'displayName': _currentUser?.displayName ?? '脑力运动员',
      'brainAge': 28,
      'chronologicalAge': 28,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // 初始化 streak 数据
    _streakData.addAll({
      'currentStreak': 0,
      'longestStreak': 0,
      'totalCheckIns': 0,
      'lastCheckIn': null,
    });
    
    // 初始化奖励数据
    _rewardsData.addAll({
      'balance': 100, // 赠送初始金币
      'totalEarned': 100,
      'totalSpent': 0,
    });
    
    _userDataController.add(_userData);
    _streakController.add(_streakData);
    _rewardsController.add(_rewardsData);
  }

  // ========== 用户数据 ==========

  static Future<Map<String, dynamic>?> getUserData() async {
    return _userData;
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    _userData.addAll(data);
    _userData['updatedAt'] = DateTime.now().toIso8601String();
    _userDataController.add(_userData);
  }

  // ========== 练习记录 ==========

  static Future<void> savePracticeSession({
    required String type,
    required int duration,
    int? score,
    Map<String, dynamic>? metadata,
  }) async {
    final session = {
      'id': 'session_${_random.nextInt(1000000)}',
      'type': type,
      'duration': duration,
      'score': score,
      'metadata': metadata ?? {},
      'completedAt': DateTime.now().toIso8601String(),
    };
    
    _practiceSessions.insert(0, session);
    
    // 限制存储数量
    if (_practiceSessions.length > 100) {
      _practiceSessions.removeLast();
    }
    
    if (kDebugMode) {
      print('✅ 练习记录已保存: $type, ${duration}秒');
    }
  }

  static Stream<List<Map<String, dynamic>>> getPracticeHistory({int limit = 50}) {
    return Stream.value(_practiceSessions.take(limit).toList());
  }

  static List<Map<String, dynamic>> getPracticeHistorySync({int limit = 50}) {
    return _practiceSessions.take(limit).toList();
  }

  // ========== Streak ==========

  static Future<void> updateStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastCheckIn,
  }) async {
    _streakData['currentStreak'] = currentStreak;
    _streakData['longestStreak'] = longestStreak;
    _streakData['lastCheckIn'] = lastCheckIn.toIso8601String();
    _streakController.add(_streakData);
  }

  static Map<String, dynamic> getStreakData() {
    return Map.from(_streakData);
  }

  // ========== 奖励系统 ==========

  static Future<void> updateBalance({
    required int balance,
    required int totalEarned,
  }) async {
    _rewardsData['balance'] = balance;
    _rewardsData['totalEarned'] = totalEarned;
    _rewardsController.add(_rewardsData);
  }

  static Future<void> addBalance(int amount) async {
    final current = _rewardsData['balance'] as int? ?? 0;
    final total = _rewardsData['totalEarned'] as int? ?? 0;
    await updateBalance(
      balance: current + amount,
      totalEarned: total + amount,
    );
  }

  static Future<void> spendBalance(int amount) async {
    final current = _rewardsData['balance'] as int? ?? 0;
    final spent = _rewardsData['totalSpent'] as int? ?? 0;
    _rewardsData['balance'] = current - amount;
    _rewardsData['totalSpent'] = spent + amount;
    _rewardsController.add(_rewardsData);
  }

  static Map<String, dynamic> getRewardsData() {
    return Map.from(_rewardsData);
  }

  // ========== 成就系统 ==========

  static Future<void> unlockAchievement(String achievementId) async {
    _achievements[achievementId] = true;
    
    // 解锁成就奖励
    await addBalance(50);
    
    if (kDebugMode) {
      print('🏆 成就解锁: $achievementId (+50金币)');
    }
  }

  static bool isAchievementUnlocked(String achievementId) {
    return _achievements[achievementId] ?? false;
  }

  static List<String> getUnlockedAchievements() {
    return _achievements.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  // ========== 数据分析 ==========

  static Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekSessions = _practiceSessions.where((s) {
      final completedAt = DateTime.tryParse(s['completedAt'] ?? '');
      return completedAt != null && completedAt.isAfter(weekAgo);
    }).toList();
    
    final totalMinutes = weekSessions.fold<int>(
      0,
      (sum, s) => sum + ((s['duration'] as int?) ?? 0),
    );
    
    final typeCount = <String, int>{};
    for (final session in weekSessions) {
      final type = session['type'] as String?;
      if (type != null) {
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }
    }
    
    return {
      'totalSessions': weekSessions.length,
      'totalMinutes': totalMinutes,
      'dailyAverage': weekSessions.isEmpty ? 0 : totalMinutes / 7,
      'typeDistribution': typeCount,
    };
  }

  /// 清理所有数据（重置应用）
  static Future<void> resetAllData() async {
    _practiceSessions.clear();
    _userData.clear();
    _streakData.clear();
    _rewardsData.clear();
    _achievements.clear();
    await signInAnonymously();
  }
}
