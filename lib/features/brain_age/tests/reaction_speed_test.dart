import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 反应速度测试 - 颜色识别
/// 屏幕显示不同颜色，当特定颜色出现时尽快点击
class ReactionSpeedTest extends StatefulWidget {
  final Function(int score, int avgReactionTimeMs, int accuracy) onComplete;
  
  const ReactionSpeedTest({
    super.key,
    required this.onComplete,
  });

  @override
  State<ReactionSpeedTest> createState() => _ReactionSpeedTestState();
}

class _ReactionSpeedTestState extends State<ReactionSpeedTest> {
  static const int totalTrials = 15;
  static const int minDelayMs = 1000;
  static const int maxDelayMs = 3000;
  
  // 颜色定义
  final List<_TestColor> colors = [
    _TestColor(name: '红色', color: const Color(0xFFE94560), shouldTap: true),
    _TestColor(name: '绿色', color: const Color(0xFF2A9D8F), shouldTap: false),
    _TestColor(name: '蓝色', color: const Color(0xFF0F3460), shouldTap: false),
    _TestColor(name: '黄色', color: const Color(0xFFF4A261), shouldTap: true),
  ];
  
  int currentTrial = 0;
  int correctCount = 0;
  int falseStarts = 0;
  List<int> reactionTimes = [];
  
  DateTime? stimulusStartTime;
  Timer? stimulusTimer;
  Timer? timeoutTimer;
  
  bool isTestRunning = false;
  bool isWaitingForStimulus = false;
  bool isWaitingForResponse = false;
  
  _TestColor? currentColor;
  
  // 反馈状态
  bool showFeedback = false;
  bool? lastResponseCorrect;
  
  @override
  void initState() {
    super.initState();
    _startTest();
  }
  
  void _startTest() {
    setState(() {
      isTestRunning = true;
      currentTrial = 0;
      correctCount = 0;
      falseStarts = 0;
      reactionTimes = [];
    });
    
    _nextTrial();
  }
  
  void _nextTrial() {
    if (currentTrial >= totalTrials) {
      _completeTest();
      return;
    }
    
    setState(() {
      isWaitingForStimulus = true;
      isWaitingForResponse = false;
      currentColor = null;
      showFeedback = false;
    });
    
    // 随机延迟后显示刺激
    final delay = minDelayMs + math.Random().nextInt(maxDelayMs - minDelayMs);
    
    stimulusTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      
      // 随机选择颜色
      final color = colors[math.Random().nextInt(colors.length)];
      
      setState(() {
        currentTrial++;
        currentColor = color;
        isWaitingForStimulus = false;
        isWaitingForResponse = true;
        stimulusStartTime = DateTime.now();
      });
      
      // 超时处理
      timeoutTimer = Timer(const Duration(milliseconds: 2000), () {
        if (isWaitingForResponse && mounted) {
          // 应该点击但没有点击
          if (currentColor?.shouldTap == true) {
            setState(() {
              showFeedback = true;
              lastResponseCorrect = false;
            });
            
            HapticFeedback.vibrate();
            
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _nextTrial();
            });
          } else {
            // 不应该点击，正确
            correctCount++;
            _nextTrial();
          }
        }
      });
    });
  }
  
  void _onTap() {
    // 如果还在等待刺激出现，属于抢跑
    if (isWaitingForStimulus) {
      falseStarts++;
      HapticFeedback.vibrate();
      
      setState(() {
        showFeedback = true;
        lastResponseCorrect = false;
      });
      
      stimulusTimer?.cancel();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _nextTrial();
      });
      return;
    }
    
    // 已经在等待响应
    if (!isWaitingForResponse || currentColor == null) return;
    
    timeoutTimer?.cancel();
    
    final shouldTap = currentColor!.shouldTap;
    final isCorrect = shouldTap;
    
    if (isCorrect) {
      // 记录反应时间
      if (stimulusStartTime != null) {
        final reactionTime = DateTime.now().difference(stimulusStartTime!).inMilliseconds;
        reactionTimes.add(reactionTime);
      }
      correctCount++;
      HapticFeedback.lightImpact();
    } else {
      // 不应该点击但点击了
      HapticFeedback.vibrate();
    }
    
    setState(() {
      isWaitingForResponse = false;
      showFeedback = true;
      lastResponseCorrect = isCorrect;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _nextTrial();
    });
  }
  
  void _completeTest() {
    setState(() {
      isTestRunning = false;
    });
    
    final accuracy = (correctCount / totalTrials * 100).toInt();
    final avgReactionTime = reactionTimes.isEmpty
        ? 0
        : reactionTimes.reduce((a, b) => a + b) ~/ reactionTimes.length;
    
    // 计算分数
    // 反应时间权重：平均<300ms得40分，<400ms得30分，<500ms得20分，<600ms得10分
    int timeScore = 0;
    if (avgReactionTime < 300) {
      timeScore = 40;
    } else if (avgReactionTime < 400) {
      timeScore = 30;
    } else if (avgReactionTime < 500) {
      timeScore = 20;
    } else if (avgReactionTime < 600) {
      timeScore = 10;
    }
    
    // 准确率权重：60%
    int accuracyScore = (accuracy * 0.6).toInt();
    
    int score = timeScore + accuracyScore;
    
    // 抢跑惩罚
    score -= (falseStarts * 5);
    score = score.clamp(0, 100);
    
    widget.onComplete(score, avgReactionTime, accuracy);
  }
  
  @override
  void dispose() {
    stimulusTimer?.cancel();
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTestRunning) {
      return _buildCompletedScreen();
    }
    
    return Column(
      children: [
        // 进度指示
        _buildProgressIndicator(),
        
        const SizedBox(height: 20),
        
        // 说明文字
        if (isWaitingForStimulus)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '准备...',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '当红色或黄色出现时，立即点击屏幕',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        
        // 主点击区域
        Expanded(
          child: GestureDetector(
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: currentColor?.color ?? AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(24),
                border: showFeedback
                    ? Border.all(
                        color: lastResponseCorrect == true
                            ? AppTheme.accentGreen
                            : AppTheme.accentCoral,
                        width: 4,
                      )
                    : null,
                boxShadow: currentColor != null
                    ? [
                        BoxShadow(
                          color: (currentColor?.color ?? Colors.transparent)
                              .withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentColor != null)
                      Text(
                        currentColor!.name,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (showFeedback)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Icon(
                          lastResponseCorrect == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: lastResponseCorrect == true
                              ? AppTheme.accentGreen
                              : Colors.white,
                          size: 64,
                        ),
                      ),
                    if (isWaitingForStimulus)
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: AppTheme.accentCoral,
                          strokeWidth: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 提示文字
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildColorIndicator('点击', const Color(0xFFE94560)),
              const SizedBox(width: 24),
              _buildColorIndicator('点击', const Color(0xFFF4A261)),
              const SizedBox(width: 24),
              _buildColorIndicator('忽略', const Color(0xFF2A9D8F)),
              const SizedBox(width: 24),
              _buildColorIndicator('忽略', const Color(0xFF0F3460)),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 统计
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$currentTrial / $totalTrials',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontFamily: 'SF Mono',
              ),
            ),
            if (falseStarts > 0) ...[
              const SizedBox(width: 16),
              Text(
                '抢跑: $falseStarts',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.accentCoral,
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 30),
      ],
    );
  }
  
  Widget _buildProgressIndicator() {
    final progress = currentTrial / totalTrials;
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.secondaryDark,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '反应速度测试',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.accentCoral,
                fontFamily: 'SF Mono',
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildColorIndicator(String action, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          action,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompletedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎯', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          '测试完成！',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        Text(
          '请等待最终评分...',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _TestColor {
  final String name;
  final Color color;
  final bool shouldTap;
  
  _TestColor({
    required this.name,
  required this.color,
    required this.shouldTap,
  });
}

/// 反应速度测试结果
class ReactionSpeedTestResult {
  final int score;
  final int avgReactionTimeMs;
  final int accuracy;
  final DateTime completedAt;
  
  ReactionSpeedTestResult({
    required this.score,
    required this.avgReactionTimeMs,
    required this.accuracy,
    required this.completedAt,
  });
  
  String get rating {
    if (score >= 90) return '优秀';
    if (score >= 75) return '良好';
    if (score >= 60) return '及格';
    return '需加强';
  }
  
  String get speedRating {
    if (avgReactionTimeMs < 300) return '极快';
    if (avgReactionTimeMs < 400) return '快';
    if (avgReactionTimeMs < 500) return '中等';
    if (avgReactionTimeMs < 600) return '偏慢';
    return '慢';
  }
}
