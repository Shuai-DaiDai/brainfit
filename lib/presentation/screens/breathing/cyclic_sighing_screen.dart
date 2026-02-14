import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/breathing_session.dart';

/// 循环叹息呼吸页面
/// 斯坦福研究验证的减压法：双吸 + 长呼
/// 60秒内显著降低应激反应
class CyclicSighingScreen extends StatefulWidget {
  const CyclicSighingScreen({super.key});

  @override
  State<CyclicSighingScreen> createState() => _CyclicSighingScreenState();
}

class _CyclicSighingScreenState extends State<CyclicSighingScreen>
    with TickerProviderStateMixin {
  
  // 循环叹息呼吸节奏（秒）
  // 吸气1 → 吸气2 → 长呼
  static const int firstInhaleSeconds = 2;
  static const int secondInhaleSeconds = 1;
  static const int exhaleSeconds = 4;
  static const int totalCycleSeconds = 7;
  
  late AnimationController _cycleController;
  late AnimationController _ballController;
  
  int _selectedDuration = 1; // 默认1分钟
  bool _isStarted = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  int _coinsEarned = 0;
  
  // 呼吸阶段: 0=第一次吸气, 1=第二次吸气, 2=呼气
  int _breathPhase = 0;
  int _completedCycles = 0;
  
  Timer? _timer;
  
  // 呼吸提示文字
  final List<String> _phaseTexts = ['第一次吸气', '第二次吸气', '慢慢呼气'];
  final List<Color> _phaseColors = [
    AppTheme.breathingInhale,
    AppTheme.breathingInhale.withOpacity(0.8),
    AppTheme.breathingExhale,
  ];

  @override
  void initState() {
    super.initState();
    
    _cycleController = AnimationController(
      duration: const Duration(seconds: totalCycleSeconds),
      vsync: this,
    );
    
    _ballController = AnimationController(
      duration: const Duration(seconds: firstInhaleSeconds),
      vsync: this,
    );
    
    _cycleController.addListener(_onCycleUpdate);
  }
  
  void _onCycleUpdate() {
    final value = _cycleController.value;
    
    // 根据动画值判断当前阶段
    // 0.0 - 0.28: 第一次吸气 (2/7)
    // 0.28 - 0.43: 第二次吸气 (1/7)
    // 0.43 - 1.0: 呼气 (4/7)
    int newPhase;
    if (value < 0.28) {
      newPhase = 0;
    } else if (value < 0.43) {
      newPhase = 1;
    } else {
      newPhase = 2;
    }
    
    if (newPhase != _breathPhase) {
      setState(() {
        _breathPhase = newPhase;
      });
      
      // 阶段切换时提供触觉反馈
      if (_breathPhase == 2) {
        // 开始呼气时轻微震动
        HapticFeedback.lightImpact();
      }
    }
  }
  
  void _startSession() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = _selectedDuration * 60;
      _completedCycles = 0;
    });
    
    HapticFeedback.mediumImpact();
    _cycleController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          
          // 每完成一个循环（7秒）奖励
          if ((_selectedDuration * 60 - _remainingSeconds) % totalCycleSeconds == 0 && 
              _remainingSeconds < _selectedDuration * 60) {
            _completedCycles++;
            _coinsEarned += 2; // 每个循环2个币
          }
        } else {
          _completeSession();
        }
      });
    });
  }
  
  void _pauseSession() {
    setState(() => _isPaused = true);
    _cycleController.stop();
    _timer?.cancel();
  }
  
  void _resumeSession() {
    setState(() => _isPaused = false);
    _cycleController.forward();
    
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
    _cycleController.stop();
    
    // 完成奖励：50-150 神经元币
    final bonus = math.Random().nextInt(100) + 50;
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
    _cycleController.removeListener(_onCycleUpdate);
    _cycleController.dispose();
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
            '循环叹息',
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
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen.withOpacity(0.3),
                  AppTheme.secondaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('🍃', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '循环叹息',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '斯坦福验证的减压法\n双吸 + 长呼，60秒显著降低应激反应',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBreathingGuide(),
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
            children: [1, 2, 3, 5].map((minutes) {
              final isSelected = _selectedDuration == minutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGreen : AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected 
                        ? Border.all(color: AppTheme.accentGreen, width: 2)
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
                gradient: LinearGradient(
                  colors: [AppTheme.accentGreen, AppTheme.accentGreen.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withOpacity(0.4),
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
  
  Widget _buildBreathingGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildGuideRow('第1次吸气', '2秒', AppTheme.breathingInhale),
          const SizedBox(height: 8),
          _buildGuideRow('第2次吸气', '1秒', AppTheme.breathingInhale.withOpacity(0.8)),
          const SizedBox(height: 8),
          _buildGuideRow('慢慢呼气', '4秒', AppTheme.breathingExhale),
        ],
      ),
    );
  }
  
  Widget _buildGuideRow(String label, String duration, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontFamily: 'SF Mono',
          ),
        ),
      ],
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
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
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
        
        // 循环次数
        Text(
          '已完成 $_completedCycles 个循环',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 呼吸阶段提示
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_breathPhase),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _phaseColors[_breathPhase].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _phaseColors[_breathPhase].withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              _phaseTexts[_breathPhase],
              style: TextStyle(
                fontSize: 20,
                color: _phaseColors[_breathPhase],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const Spacer(),
        
        // 呼吸球动画
        AnimatedBuilder(
          animation: _cycleController,
          builder: (context, child) {
            // 计算球的缩放比例
            double scale;
            final value = _cycleController.value;
            
            if (value < 0.28) {
              // 第一次吸气：0.5 -> 0.75
              scale = 0.5 + (value / 0.28) * 0.25;
            } else if (value < 0.43) {
              // 第二次吸气：0.75 -> 0.9
              final t = (value - 0.28) / 0.15;
              scale = 0.75 + t * 0.15;
            } else {
              // 呼气：0.9 -> 0.5
              final t = (value - 0.43) / 0.57;
              scale = 0.9 - t * 0.4;
            }
            
            // 颜色随阶段变化
            Color color;
            if (_breathPhase == 0) {
              color = AppTheme.breathingInhale;
            } else if (_breathPhase == 1) {
              color = Color.lerp(
                AppTheme.breathingInhale,
                AppTheme.breathingExhale,
                0.5,
              )!;
            } else {
              color = AppTheme.breathingExhale;
            }
            
            return Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 220 * scale,
                  height: 220 * scale,
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
                        color: color.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 15,
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
                    color: AppTheme.accentGreen.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 32,
                  color: AppTheme.accentGreen,
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
            const SizedBox(height: 8),
            Text(
              '完成 $_completedCycles 个循环叹息',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentGreen, AppTheme.accentGreen.withOpacity(0.8)],
                ),
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
                  color: AppTheme.accentGreen,
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
