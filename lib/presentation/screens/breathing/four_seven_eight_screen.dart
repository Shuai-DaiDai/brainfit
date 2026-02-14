import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptic_service.dart';

/// 4-7-8呼吸页面
/// 经典放松呼吸法：吸气4秒 - 屏息7秒 - 呼气8秒
class FourSevenEightScreen extends StatefulWidget {
  const FourSevenEightScreen({super.key});

  @override
  State<FourSevenEightScreen> createState() => _FourSevenEightScreenState();
}

class _FourSevenEightScreenState extends State<FourSevenEightScreen>
    with TickerProviderStateMixin {
  
  // 呼吸阶段
  enum Phase { inhale, hold, exhale, idle }
  Phase currentPhase = Phase.idle;
  
  // 计时器
  int remainingSeconds = 0;
  Timer? _timer;
  
  // 当前循环
  int currentCycle = 0;
  final int totalCycles = 4; // 4个循环是标准做法
  
  // 动画
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;
  
  // 时长配置
  final int inhaleSeconds = 4;
  final int holdSeconds = 7;
  final int exhaleSeconds = 8;
  
  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: Duration(seconds: inhaleSeconds),
      vsync: this,
    );
    _circleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
  }
  
  void _startSession() {
    setState(() {
      currentPhase = Phase.inhale;
      currentCycle = 1;
      remainingSeconds = inhaleSeconds;
    });
    _startPhase();
    HapticService.heavy();
  }
  
  void _startPhase() {
    _timer?.cancel();
    
    // 根据阶段设置动画
    switch (currentPhase) {
      case Phase.inhale:
        _circleController.duration = Duration(seconds: inhaleSeconds);
        _circleController.forward(from: 0.3);
        break;
      case Phase.hold:
        // 保持当前大小
        break;
      case Phase.exhale:
        _circleController.duration = Duration(seconds: exhaleSeconds);
        _circleController.reverse(from: 1.0);
        break;
      case Phase.idle:
        return;
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });
      
      if (remainingSeconds <= 0) {
        _nextPhase();
      } else {
        // 每秒轻微震动
        HapticService.light();
      }
    });
  }
  
  void _nextPhase() {
    switch (currentPhase) {
      case Phase.inhale:
        setState(() {
          currentPhase = Phase.hold;
          remainingSeconds = holdSeconds;
        });
        HapticService.medium();
        break;
      case Phase.hold:
        setState(() {
          currentPhase = Phase.exhale;
          remainingSeconds = exhaleSeconds;
        });
        HapticService.medium();
        break;
      case Phase.exhale:
        if (currentCycle < totalCycles) {
          setState(() {
            currentCycle++;
            currentPhase = Phase.inhale;
            remainingSeconds = inhaleSeconds;
          });
          HapticService.heavy();
        } else {
          _completeSession();
          return;
        }
        break;
      case Phase.idle:
        return;
    }
    _startPhase();
  }
  
  void _completeSession() {
    _timer?.cancel();
    setState(() {
      currentPhase = Phase.idle;
    });
    HapticService.success();
    _showCompletionDialog();
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                '练习完成',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '完成了 $totalCycles 个4-7-8循环',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '你应该感到更加放松了',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            _buildAppBar(),
            
            // 主要内容
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 循环指示器
                  if (currentPhase != Phase.idle)
                    _buildCycleIndicator(),
                  
                  const SizedBox(height: 40),
                  
                  // 呼吸球
                  _buildBreathingCircle(),
                  
                  const SizedBox(height: 40),
                  
                  // 阶段提示
                  _buildPhaseInfo(),
                  
                  const SizedBox(height: 40),
                  
                  // 计时显示
                  if (currentPhase != Phase.idle)
                    _buildTimer(),
                ],
              ),
            ),
            
            // 底部控制
            _buildBottomControl(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _timer?.cancel();
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const Spacer(),
          Text(
            '4-7-8呼吸',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildCycleIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCycles, (index) {
        final isCompleted = index < currentCycle - 1;
        final isCurrent = index == currentCycle - 1;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 24,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.accentPurple
                : isCurrent
                    ? AppTheme.accentPurple.withOpacity(0.5)
                    : AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
  
  Widget _buildBreathingCircle() {
    final phaseColor = currentPhase == Phase.idle
        ? AppTheme.accentPurple.withOpacity(0.3)
        : AppTheme.accentPurple;
    
    return AnimatedBuilder(
      animation: _circleAnimation,
      builder: (context, child) {
        final size = 200 + (_circleAnimation.value * 100);
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                phaseColor.withOpacity(0.8),
                phaseColor.withOpacity(0.2),
              ],
            ),
            boxShadow: currentPhase != Phase.idle
                ? [
                    BoxShadow(
                      color: phaseColor.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              currentPhase == Phase.idle ? '🌙' : _getPhaseEmoji(),
              style: const TextStyle(fontSize: 48),
            ),
          ),
        );
      },
    );
  }
  
  String _getPhaseEmoji() {
    switch (currentPhase) {
      case Phase.inhale:
        return '👃';
      case Phase.hold:
        return '😌';
      case Phase.exhale:
        return '💨';
      case Phase.idle:
        return '🌙';
    }
  }
  
  Widget _buildPhaseInfo() {
    final String phaseText;
    final String instruction;
    
    switch (currentPhase) {
      case Phase.inhale:
        phaseText = '吸气';
        instruction = '用鼻子缓慢吸气';
        break;
      case Phase.hold:
        phaseText = '屏息';
        instruction = '保持呼吸，放松身体';
        break;
      case Phase.exhale:
        phaseText = '呼气';
        instruction = '用嘴缓慢呼气，发出嘶嘶声';
        break;
      case Phase.idle:
        phaseText = '准备';
        instruction = '找一个舒适的姿势';
        break;
    }
    
    return Column(
      children: [
        Text(
          phaseText,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: currentPhase == Phase.idle
                ? AppTheme.textSecondary
                : AppTheme.accentPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          instruction,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        if (currentPhase != Phase.idle) ...[
          const SizedBox(height: 8),
          Text(
            '${_getPhaseSeconds()}秒',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ],
    );
  }
  
  int _getPhaseSeconds() {
    switch (currentPhase) {
      case Phase.inhale:
        return inhaleSeconds;
      case Phase.hold:
        return holdSeconds;
      case Phase.exhale:
        return exhaleSeconds;
      case Phase.idle:
        return 0;
    }
  }
  
  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$remainingSeconds',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'SF Mono',
        ),
      ),
    );
  }
  
  Widget _buildBottomControl() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (currentPhase == Phase.idle)
            GestureDetector(
              onTap: _startSession,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '开始练习',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      setState(() {
                        currentPhase = Phase.idle;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '停止',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            '4-7-8呼吸法：吸气4秒 - 屏息7秒 - 呼气8秒',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
