import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/breathing_session.dart';

/// 共振呼吸页面
class ResonantBreathingScreen extends StatefulWidget {
  const ResonantBreathingScreen({super.key});

  @override
  State<ResonantBreathingScreen> createState() => _ResonantBreathingScreenState();
}

class _ResonantBreathingScreenState extends State<ResonantBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _ballController;
  
  int _selectedDuration = 2; // 默认2分钟
  bool _isStarted = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  int _coinsEarned = 0;
  
  // 呼吸阶段: 0=吸气, 1=呼气
  int _breathPhase = 0;
  
  Timer? _timer;
  
  // 呼吸配置
  static const int inhaleSeconds = 5;
  static const int exhaleSeconds = 5;
  static const int cycleSeconds = inhaleSeconds + exhaleSeconds;
  
  @override
  void initState() {
    super.initState();
    
    _breathController = AnimationController(
      duration: const Duration(seconds: cycleSeconds),
      vsync: this,
    );
    
    _ballController = AnimationController(
      duration: const Duration(seconds: inhaleSeconds),
      vsync: this,
    );
    
    _breathController.addStatusListener(_onBreathStatusChanged);
  }
  
  void _onBreathStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _breathPhase = 1);
      _breathController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      setState(() => _breathPhase = 0);
      _breathController.forward();
    }
  }
  
  void _startSession() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = _selectedDuration * 60;
    });
    
    HapticFeedback.mediumImpact();
    _breathController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          // 每10秒奖励1个神经元币
          if ((_selectedDuration * 60 - _remainingSeconds) % 10 == 0) {
            _coinsEarned += 1;
          }
        } else {
          _completeSession();
        }
      });
    });
  }
  
  void _pauseSession() {
    setState(() => _isPaused = true);
    _breathController.stop();
    _timer?.cancel();
  }
  
  void _resumeSession() {
    setState(() => _isPaused = false);
    _breathPhase == 0 ? _breathController.forward() : _breathController.reverse();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }
  
  void _completeSession() {
    _timer?.cancel();
    _breathController.stop();
    
    // 随机奖励：50-200 神经元币
    final bonus = math.Random().nextInt(150) + 50;
    setState(() => _coinsEarned += bonus);
    
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _ballController.dispose();
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
            
            Expanded(
              child: _isStarted ? _buildActiveSession() : _buildSetupView(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Text(
            '共振呼吸',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🧬', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$_coinsEarned',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 说明卡片
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('🌊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '共振呼吸',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '5.5秒呼吸周期，最大化HRV，快速激活副交感神经',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 时长选择
          Text(
            '选择练习时长',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [2, 5, 10, 15].map((minutes) {
              final isSelected = _selectedDuration == minutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentCoral : AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected 
                        ? Border.all(color: AppTheme.accentCoral, width: 2)
                        : null,
                  ),
                  child: Text(
                    '$minutes分钟',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          // 开始按钮
          GestureDetector(
            onTap: _startSession,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCoral.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '开始练习',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveSession() {
    final progress = 1 - (_remainingSeconds / (_selectedDuration * 60));
    
    return Column(
      children: [
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.secondaryDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 倒计时
        Text(
          '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 呼吸阶段提示
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _breathPhase == 0 ? '吸气' : '呼气',
            key: ValueKey(_breathPhase),
            style: TextStyle(
              fontSize: 24,
              color: _breathPhase == 0 
                  ? AppTheme.breathingInhale 
                  : AppTheme.breathingExhale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const Spacer(),
        
        // 呼吸球动画
        AnimatedBuilder(
          animation: _breathController,
          builder: (context, child) {
            final scale = 0.5 + (_breathController.value * 0.5);
            final color = Color.lerp(
              AppTheme.breathingExhale,
              AppTheme.breathingInhale,
              _breathController.value,
            );
            
            return Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color!,
                    color.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 200 * scale,
                  height: 200 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color,
                        color.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        const Spacer(),
        
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isPaused ? _resumeSession : _pauseSession,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentCoral.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 32,
                  color: AppTheme.accentCoral,
                ),
              ),
            ),
            const SizedBox(width: 32),
            GestureDetector(
              onTap: _completeSession,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.textMuted.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.stop,
                  size: 32,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildCompletionDialog() {
    return Dialog(
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
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '练习完成！',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '获得奖励',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🧬 $_coinsEarned',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.accentCoral,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '继续',
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
    );
  }
}
