import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/breathing_session.dart';
import '../../data/models/brain_age_test.dart';

/// 本地存储服务
class LocalStorageService {
  static late Box<UserModel> _userBox;
  static late Box<BreathingSession> _breathingBox;
  static late Box<BrainAgeTest> _brainAgeBox;
  static late Box<dynamic> _settingsBox;
  
  /// 初始化本地存储
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // 注册适配器
    // Hive.registerAdapter(UserModelAdapter());
    // Hive.registerAdapter(BreathingSessionAdapter());
    // Hive.registerAdapter(BrainAgeTestAdapter());
    
    // 打开盒子
    _userBox = await Hive.openBox<UserModel>('user');
    _breathingBox = await Hive.openBox<BreathingSession>('breathing');
    _brainAgeBox = await Hive.openBox<BrainAgeTest>('brain_age');
    _settingsBox = await Hive.openBox<dynamic>('settings');
  }
  
  // ========== 用户数据 ==========
  
  static UserModel? getCurrentUser() {
    return _userBox.get('current_user');
  }
  
  static Future<void> saveUser(UserModel user) async {
    await _userBox.put('current_user', user);
  }
  
  // ========== 呼吸练习 ==========
  
  static List<BreathingSession> getBreathingSessions() {
    return _breathingBox.values.toList();
  }
  
  static Future<void> saveBreathingSession(BreathingSession session) async {
    await _breathingBox.put(session.id, session);
  }
  
  // ========== 脑力年龄测试 ==========
  
  static BrainAgeTest? getLastBrainAgeTest() {
    if (_brainAgeBox.isEmpty) return null;
    return _brainAgeBox.values.last;
  }
  
  static Future<void> saveBrainAgeTest(BrainAgeTest test) async {
    await _brainAgeBox.put(test.id, test);
  }
  
  // ========== 设置 ==========
  
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
  
  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }
  
  // ========== 便捷属性 ==========
  
  static bool get hasCompletedOnboarding => 
      getSetting<bool>('has_completed_onboarding', defaultValue: false) ?? false;
  
  static set hasCompletedOnboarding(bool value) => 
      setSetting('has_completed_onboarding', value);
  
  static bool get hasTakenBrainAgeTest => 
      getSetting<bool>('has_taken_brain_age_test', defaultValue: false) ?? false;
  
  static set hasTakenBrainAgeTest(bool value) => 
      setSetting('has_taken_brain_age_test', value);
  
  static DateTime? get lastActiveDate => 
      getSetting<String>('last_active_date') != null
          ? DateTime.parse(getSetting<String>('last_active_date')!)
          : null;
  
  static set lastActiveDate(DateTime? date) => 
      setSetting('last_active_date', date?.toIso8601String());
  
  /// 清除所有数据（注销时使用）
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _breathingBox.clear();
    await _brainAgeBox.clear();
    await _settingsBox.clear();
  }
}
