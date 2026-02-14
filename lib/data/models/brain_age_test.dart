import 'package:freezed_annotation/freezed_annotation.dart';

part 'brain_age_test.freezed.dart';
part 'brain_age_test.g.dart';

/// 脑力年龄测试类型
enum BrainAgeTestType {
  attentionSpan,    // 注意力广度测试
  workingMemory,    // 工作记忆测试
  reactionSpeed,    // 反应速度测试
}

/// 脑力年龄测试结果
@freezed
class BrainAgeTest with _$BrainAgeTest {
  const factory BrainAgeTest({
    required String id,
    required String userId,
    required DateTime completedAt,
    
    // 各项分数
    @Default(0) int attentionScore,      // 注意力分数 0-100
    @Default(0) int memoryScore,         // 记忆力分数 0-100
    @Default(0) int reactionScore,       // 反应速度分数 0-100
    
    // 综合结果
    @Default(25) int chronologicalAge,   // 实际年龄
    @Default(25) int brainAge,           // 脑力年龄
    @Default(0) int brainAgeDelta,       // 差值
    
    // 详细数据
    @Default([]) List<AttentionTestResult> attentionResults,
    @Default([]) List<MemoryTestResult> memoryResults,
    @Default([]) List<ReactionTestResult> reactionResults,
    
    // 分析与建议
    String? analysis,
    @Default([]) List<String> recommendations,
  }) = _BrainAgeTest;

  factory BrainAgeTest.fromJson(Map<String, dynamic> json) =>
      _$BrainAgeTestFromJson(json);

  // 计算综合分数
  double get averageScore => (attentionScore + memoryScore + reactionScore) / 3;
  
  // 计算脑力年龄（简化算法）
  static int calculateBrainAge(int chronologicalAge, double averageScore) {
    // 基础算法：50分对应实际年龄，每高10分减2岁，每低10分加2岁
    final deviation = (averageScore - 50) / 10 * 2;
    final calculated = chronologicalAge - deviation.round();
    return calculated.clamp(18, 80); // 限制在18-80岁之间
  }
}

/// 注意力测试结果
@freezed
class AttentionTestResult with _$AttentionTestResult {
  const factory AttentionTestResult({
    required int level,           // 测试等级
    required int targetCount,     // 目标数量
    required int correctCount,    // 正确数量
    required int wrongCount,      // 错误数量
    required int missedCount,     // 遗漏数量
    required Duration duration,   // 用时
  }) = _AttentionTestResult;

  factory AttentionTestResult.fromJson(Map<String, dynamic> json) =>
      _$AttentionTestResultFromJson(json);
  
  double get accuracy => targetCount > 0 ? correctCount / targetCount : 0;
  double get reactionTimeMs => duration.inMilliseconds / (correctCount + wrongCount);
}

/// 记忆测试结果
@freezed
class MemoryTestResult with _$MemoryTestResult {
  const factory MemoryTestResult({
    required int nLevel,          // N-Back等级
    required int totalTrials,     // 总试次
    required int correctCount,    // 正确数量
    required int falsePositives,  // 误报数量
    required Duration avgReactionTime,
  }) = _MemoryTestResult;

  factory MemoryTestResult.fromJson(Map<String, dynamic> json) =>
      _$MemoryTestResultFromJson(json);
  
  double get accuracy => totalTrials > 0 ? correctCount / totalTrials : 0;
  double get dPrime {
    // 信号检测论d'值
    final hitRate = accuracy.clamp(0.01, 0.99);
    final faRate = (falsePositives / totalTrials).clamp(0.01, 0.99);
    return _zScore(hitRate) - _zScore(faRate);
  }
  
  static double _zScore(double p) {
    // 简化的z-score计算
    return -0.862 + (1.06 * (p - 0.5).abs().sqrt()) * (p > 0.5 ? 1 : -1);
  }
}

/// 反应速度测试结果
@freezed
class ReactionTestResult with _$ReactionTestResult {
  const factory ReactionTestResult({
    required int totalTrials,
    required int correctCount,
    required Duration avgReactionTime,
    required Duration minReactionTime,
    required Duration maxReactionTime,
  }) = _ReactionTestResult;

  factory ReactionTestResult.fromJson(Map<String, dynamic> json) =>
      _$ReactionTestResultFromJson(json);
  
  double get accuracy => totalTrials > 0 ? correctCount / totalTrials : 0;
  int get avgMs => avgReactionTime.inMilliseconds;
}
