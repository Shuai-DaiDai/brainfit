import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 注意力广度测试 - 舒尔特方格 (Schulte Grid)
/// 用户需要按顺序点击 1-25 的数字
class AttentionSpanTest extends StatefulWidget {
  final Function(int score, int timeMs, int errors) onComplete;
  
  const AttentionSpanTest({
    super.key,
    required this.onComplete,
  });

  @override
  State<AttentionSpanTest> createState() => _AttentionSpanTestState();
}

class _AttentionSpanTestState extends State<AttentionSpanTest> {
  late List<int> numbers;
  int currentTarget = 1;
  int errors = 0;
  DateTime? startTime;
  Timer? timer;
  int elapsedSeconds = 0;
  bool isCompleted = false;
  
  // 动画效果
  int? lastClickedIndex;
  bool showError = false;
  
  @override
  void initState() {
    super.initState();
    _generateNumbers();
  }
  
  void _generateNumbers() {
    numbers = List.generate(25, (i) => i + 1);
    numbers.shuffle();
  }
  
  void _startTest() {
    if (startTime == null) {
      setState(() {
        startTime = DateTime.now();
      });
      
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          elapsedSeconds++;
        });
      });
    }
  }
  
  void _onNumberTap(int index) {
    _startTest();
    
    if (isCompleted) return;
    
    final tappedNumber = numbers[index];
    
    if (tappedNumber == currentTarget) {
      // 正确点击
      HapticFeedback.lightImpact();
      
      setState(() {
        lastClickedIndex = index;
        currentTarget++;
      });
      
      // 清除动画状态
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            lastClickedIndex = null;
          });
        }
      });
      
      // 完成测试
      if (currentTarget > 25) {
        _completeTest();
      }
    } else {
      // 错误点击
      HapticFeedback.vibrate();
      
      setState(() {
        errors++;
        showError = true;
      });
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            showError = false;
          });
        }
      });
    }
  }
  
  void _completeTest() {
    timer?.cancel();
    
    final endTime = DateTime.now();
    final timeMs = endTime.difference(startTime!).inMilliseconds;
    
    // 计算分数：基于时间和错误数
    // 优秀：30秒内，良好：45秒内，及格：60秒内
    int score;
    if (timeMs <= 30000 && errors == 0) {
      score = 100;
    } else if (timeMs <= 45000 && errors <= 2) {
      score = 85;
    } else if (timeMs <= 60000 && errors <= 5) {
      score = 70;
    } else {
      score = math.max(40, 100 - (timeMs ~/ 1000) - (errors * 5));
    }
    
    setState(() {
      isCompleted = true;
    });
    
    widget.onComplete(score, timeMs, errors);
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  String get _timeString {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部状态栏
        _buildStatusBar(),
        
        const SizedBox(height: 20),
        
        // 游戏区域
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 25,
              itemBuilder: (context, index) {
                return _buildNumberCell(index);
              },
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 说明文字
        Text(
          '按顺序点击数字 1 → 25',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        
        const SizedBox(height: 30),
      ],
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('目标', '$currentTarget', AppTheme.accentCoral),
          _buildStatusItem('时间', _timeString, AppTheme.textPrimary),
          _buildStatusItem('错误', '$errors', AppTheme.textMuted),
        ],
      ),
    );
  }
  
  Widget _buildStatusItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: 'SF Mono',
          ),
        ),
      ],
    );
  }
  
  Widget _buildNumberCell(int index) {
    final number = numbers[index];
    final isClicked = number < currentTarget;
    final isLastClicked = index == lastClickedIndex;
    final isTarget = number == currentTarget;
    
    return GestureDetector(
      onTap: () => _onNumberTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isClicked 
              ? AppTheme.accentCoral.withOpacity(0.3)
              : isTarget
                  ? AppTheme.accentCoral.withOpacity(0.1)
                  : AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isClicked
                ? AppTheme.accentCoral
                : isTarget
                    ? AppTheme.accentCoral.withOpacity(0.5)
                    : Colors.transparent,
            width: isClicked || isTarget ? 2 : 0,
          ),
          boxShadow: isLastClicked
              ? [
                  BoxShadow(
                    color: AppTheme.accentCoral.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isClicked
                  ? AppTheme.accentCoral
                  : isTarget
                      ? AppTheme.accentCoral
                      : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 注意力测试结果数据
class AttentionTestResult {
  final int score;
  final int timeMs;
  final int errors;
  final DateTime completedAt;
  
  AttentionTestResult({
    required this.score,
    required this.timeMs,
    required this.errors,
    required this.completedAt,
  });
  
  double get timeSeconds => timeMs / 1000;
  
  String get rating {
    if (score >= 90) return '优秀';
    if (score >= 75) return '良好';
    if (score >= 60) return '及格';
    return '需加强';
  }
  
  String get analysis {
    if (score >= 90) {
      return '你的注意力广度非常出色，能够快速准确地处理多个信息源。';
    } else if (score >= 75) {
      return '你的注意力表现良好，继续保持练习可以进一步提升。';
    } else if (score >= 60) {
      return '你的注意力有一定的基础，建议每天进行10分钟专注训练。';
    } else {
      return '你的注意力需要加强训练，短视频可能已经开始影响你的专注能力。';
    }
  }
}
