import 'package:freezed_annotation/freezed_annotation.dart';

part 'breathing_session.freezed.dart';
part 'breathing_session.g.dart';

/// 呼吸练习类型
enum BreathingType {
  resonant,      // 共振呼吸
  cyclicSighing, // 循环叹息
  fourSevenEight, // 4-7-8呼吸
  boxBreathing,  // 箱式呼吸
}

/// 呼吸练习会话
@freezed
class BreathingSession with _$BreathingSession {
  const factory BreathingSession({
    required String id,
    required String userId,
    required BreathingType type,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,     // 练习时长（秒）
    
    // HRV数据（可选）
    int? heartRateBefore,
    int? heartRateAfter,
    double? hrvBefore,
    double? hrvAfter,
    
    // 奖励
    @Default(0) int coinsEarned,
    @Default(false) bool isCompleted,
    String? notes,
  }) = _BreathingSession;

  factory BreathingSession.fromJson(Map<String, dynamic> json) =>
      _$BreathingSessionFromJson(json);
}

/// 呼吸练习配置
class BreathingConfig {
  final String name;
  final String description;
  final String icon;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdEmptySeconds;
  final int defaultDurationMinutes;
  final List<int> durationOptions;

  const BreathingConfig({
    required this.name,
    required this.description,
    required this.icon,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdEmptySeconds = 0,
    required this.defaultDurationMinutes,
    required this.durationOptions,
  });

  // 共振呼吸配置 - 5.5秒周期
  static const BreathingConfig resonant = BreathingConfig(
    name: '共振呼吸',
    description: '5.5秒呼吸周期，最大化HRV，快速平静',
    icon: '🌊',
    inhaleSeconds: 5,
    holdSeconds: 0,
    exhaleSeconds: 5,
    defaultDurationMinutes: 2,
    durationOptions: [2, 5, 10, 15],
  );

  // 循环叹息配置 - 双吸+长呼
  static const BreathingConfig cyclicSighing = BreathingConfig(
    name: '循环叹息',
    description: '斯坦福验证的减压法，60秒显著降低应激',
    icon: '🍃',
    inhaleSeconds: 2,
    holdSeconds: 0,
    exhaleSeconds: 4,
    defaultDurationMinutes: 1,
    durationOptions: [1, 2, 3, 5],
  );

  // 4-7-8呼吸配置
  static const BreathingConfig fourSevenEight = BreathingConfig(
    name: '4-7-8呼吸',
    description: '经典放松呼吸法，助眠神器',
    icon: '🌙',
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
    defaultDurationMinutes: 4,
    durationOptions: [4, 8, 12],
  );

  // 箱式呼吸配置
  static const BreathingConfig box = BreathingConfig(
    name: '箱式呼吸',
    description: '海军海豹同款，提升专注和冷静',
    icon: '⬜',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    holdEmptySeconds: 4,
    defaultDurationMinutes: 5,
    durationOptions: [3, 5, 10],
  );

  int get totalCycleSeconds => inhaleSeconds + holdSeconds + exhaleSeconds + holdEmptySeconds;
  
  double get inhaleRatio => inhaleSeconds / totalCycleSeconds;
  double get holdRatio => holdSeconds / totalCycleSeconds;
  double get exhaleRatio => exhaleSeconds / totalCycleSeconds;
  double get holdEmptyRatio => holdEmptySeconds / totalCycleSeconds;
}
