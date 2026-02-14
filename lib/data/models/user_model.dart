import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 用户模型
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    
    // 脑力数据
    @Default(25) int chronologicalAge,      // 实际年龄
    @Default(25) int brainAge,               // 脑力年龄
    @Default(0) int brainAgeDelta,           // 脑力年龄差值（负数=更好）
    @Default(0.0) double attentionScore,     // 注意力分数 0-100
    @Default(0.0) double memoryScore,        // 记忆力分数 0-100
    @Default(0.0) double reactionScore,      // 反应速度分数 0-100
    
    // 游戏化数据
    @Default(0) int neuronCoins,             // 神经元币
    @Default(0) int currentStreak,           // 当前连续天数
    @Default(0) int longestStreak,           // 最长连续天数
    @Default(0) int totalPracticeMinutes,    // 总练习时长（分钟）
    @Default(0) int totalSessions,           // 总练习次数
    
    // 解锁内容
    @Default(false) bool hasCompletedOnboarding,
    @Default(false) bool hasTakenBrainAgeTest,
    @Default([]) List<String> unlockedAchievements,
    @Default([]) List<String> unlockedScenes,
    
    // 时间戳
    required DateTime createdAt,
    DateTime? lastActiveAt,
    DateTime? lastStreakDate,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
