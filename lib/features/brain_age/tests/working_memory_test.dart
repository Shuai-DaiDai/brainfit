import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 工作记忆测试 - N-Back 变体
/// 屏幕上依次显示数字，用户需要判断当前数字是否与N个位置前的数字相同
class WorkingMemoryTest extends StatefulWidget {
  final Function(int score, int nLevel, double accuracy, int avgReactionTimeMs) onComplete;
  
  const WorkingMemoryTest({
    super.key,
    required this.onComplete,
  });

  @override
  State<WorkingMemoryTest> createState() => _WorkingMemoryTestState();
}

class _WorkingMemoryTestState extends State<WorkingMemoryTest> {
  static const int nLevel = 2; // 使用 2-back 作为测试标准
  static const int totalTrials = 20; // 总共20个试次
  static const int stimulusDurationMs = 2500; // 每个刺激显示2.5秒
  
  List<int> sequence = [];
  int currentIndex = -1;
  int correctCount = 0;
  int falsePositives = 0;
  int misses = 0;
  
  DateTime? stimulusStartTime;
  List<int> reactionTimes = [];
  
  Timer? stimulusTimer;
  bool isTestRunning = false;
  bool isWaitingForResponse = false;
  
  // 当前显示的数字
  int? currentNumber;
  
  // 动画状态
  bool showFeedback = false;
  bool? lastResponseCorrect;
  
  @override
  void initState() {
    super.initState();
    _generateSequence();
  }
  
  void _generateSequence() {
    final random = math.Random();
    sequence = [];
    
    // 生成序列，确保有一定比例的匹配项（约30%）
    for (int i = 0; i < totalTrials; i++) {
      if (i >= nLevel && random.nextDouble() < 0.3) {
        // 30%概率与N个位置前相同
        sequence.add(sequence[i - nLevel]);
      } else {
        // 70%概率随机生成
        sequence.add(random.nextInt(9) + 1);
      }
    }
  }
  
  void _startTest() {
    setState(() {
      isTestRunning = true;
      currentIndex = -1;
      correctCount = 0;
      falsePositives = 0;
      misses = 0;
      reactionTimes = [];
    });
    
    _nextStimulus();
  }
  
  void _nextStimulus() {
    if (currentIndex >= totalTrials - 1) {
      _completeTest();
      return;
    }
    
    setState(() {
      currentIndex++;
      currentNumber = sequence[currentIndex];
      isWaitingForResponse = true;
      stimulusStartTime = DateTime.now();
      showFeedback = false;
    });
    
    // 自动进入下一个刺激
    stimulusTimer = Timer(const Duration(milliseconds: stimulusDurationMs), () {
      if (isWaitingForResponse) {
        // 用户没有响应，检查是否应该响应
        final shouldRespond = _shouldRespond();
        if (shouldRespond) {
          setState(() {
            misses++;
          });
        }
        _nextStimulus();
      }
    });
  }
  
  bool _shouldRespond() {
    if (currentIndex < nLevel) return false;
    return sequence[currentIndex] == sequence[currentIndex - nLevel];
  }
  
  void _onResponse(bool respondedMatch) {
    if (!isWaitingForResponse) return;
    
    stimulusTimer?.cancel();
    
    final shouldRespond = _shouldRespond();
    final isCorrect = respondedMatch == shouldRespond;
    
    // 记录反应时间
    if (stimulusStartTime != null) {
      final reactionTime = DateTime.now().difference(stimulusStartTime!).inMilliseconds;
      reactionTimes.add(reactionTime);
    }
    
    setState(() {
      isWaitingForResponse = false;
      showFeedback = true;
      lastResponseCorrect = isCorrect;
      
      if (isCorrect) {
        correctCount++;
      } else if (respondedMatch && !shouldRespond) {
        falsePositives++;
      } else if (!respondedMatch && shouldRespond) {
        misses++;
      }
    });
    
    // 触觉反馈
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
    
    // 延迟后进入下一个
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _nextStimulus();
      }
    });
  }
  
  void _completeTest() {
    setState(() {
      isTestRunning = false;
    });
    
    final accuracy = correctCount / totalTrials;
    final avgReactionTime = reactionTimes.isEmpty 
        ? 0 
        : reactionTimes.reduce((a, b) => a + b) ~/ reactionTimes.length;
    
    // 计算分数：准确率占70%，反应时间占30%
    int score = (accuracy * 70).toInt();
    
    // 反应时间加分：平均<800ms加30分，<1200ms加20分，<1500ms加10分
    if (avgReactionTime < 800) {
      score += 30;
    } else if (avgReactionTime < 1200) {
      score += 20;
    } else if (avgReactionTime < 1500) {
      score += 10;
    }
    
    score = score.clamp(0, 100);
    
    widget.onComplete(score, nLevel, accuracy, avgReactionTime);
  }
  
  @override
  void dispose() {
    stimulusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTestRunning && currentIndex == -1) {
      return _buildStartScreen();
    }
    
    if (!isTestRunning && currentIndex >= totalTrials - 1) {
      return _buildCompletedScreen();
    }
    
    return _buildTestScreen();
  }
  
  Widget _buildStartScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('🧩', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                '工作记忆测试',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '屏幕上会依次出现数字\n当当前数字与2个位置前的数字相同时，点击"相同"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildInstructionCard(),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _startTest,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          ),
          child: const Text('开始测试', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
  
  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '示例序列：3 → 7 → 3 → 5',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 第1个数字 3：不操作',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          Text(
            '• 第2个数字 7：不操作',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          Text(
            '• 第3个数字 3：点击"相同" ✓',
            style: TextStyle(color: AppTheme.accentGreen, fontSize: 13),
          ),
          Text(
            '• 第4个数字 5：不操作',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestScreen() {
    final progress = (currentIndex + 1) / totalTrials;
    
    return Column(
      children: [
        // 进度条
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.secondaryDark,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
          minHeight: 6,
        ),
        
        const SizedBox(height: 20),
        
        // 数字显示区域
        Expanded(
          flex: 2,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: showFeedback
                    ? (lastResponseCorrect == true
                        ? AppTheme.accentGreen.withOpacity(0.2)
                        : AppTheme.accentCoral.withOpacity(0.2))
                    : AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: showFeedback
                      ? (lastResponseCorrect == true
                          ? AppTheme.accentGreen
                          : AppTheme.accentCoral)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  currentNumber?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Mono',
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // 反馈图标
        if (showFeedback)
          Icon(
            lastResponseCorrect == true ? Icons.check_circle : Icons.cancel,
            color: lastResponseCorrect == true
                ? AppTheme.accentGreen
                : AppTheme.accentCoral,
            size: 48,
          ),
        
        const SizedBox(height: 20),
        
        // 响应按钮
        Row(
          children: [
            Expanded(
              child: _buildResponseButton(
                label: '不同',
                color: AppTheme.secondaryDark,
                onTap: () => _onResponse(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildResponseButton(
                label: '相同',
                color: AppTheme.accentCoral,
                onTap: () => _onResponse(true),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 统计
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${currentIndex + 1} / $totalTrials',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
      ],
    );
  }
  
  Widget _buildResponseButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: color == AppTheme.accentCoral
              ? [
                  BoxShadow(
                    color: AppTheme.accentCoral.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color == AppTheme.accentCoral
                  ? Colors.white
                  : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompletedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
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

/// 工作记忆测试结果
class WorkingMemoryTestResult {
  final int score;
  final int nLevel;
  final double accuracy;
  final int avgReactionTimeMs;
  final DateTime completedAt;
  
  WorkingMemoryTestResult({
    required this.score,
    required this.nLevel,
    required this.accuracy,
    required this.avgReactionTimeMs,
    required this.completedAt,
  });
  
  String get rating {
    if (score >= 90) return '优秀';
    if (score >= 75) return '良好';
    if (score >= 60) return '及格';
    return '需加强';
  }
}
