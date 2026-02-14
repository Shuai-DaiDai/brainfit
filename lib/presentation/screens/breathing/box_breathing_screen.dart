import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptic_service.dart';

/// 箱式呼吸页面（又称方块呼吸、盒式呼吸）
/// 海军海豹同款：吸气4秒 - 屏息4秒 - 呼气4秒 - 屏息4秒
class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with TickerProviderStateMixin {
  
  // 呼吸阶段
  enum Phase { inhale, hold1, exhale, hold2, idle }
  Phase currentPhase = Phase.idle;
  
  // 计时器
  int remainingSeconds = 0;
  Timer? _timer;
  
  // 当前循环
  int currentCycle = 0;
  int totalCycles = 10; // 默认10个循环
  
  // 动画
  late AnimationController _animationController;
  
  // 时长配置（箱式呼吸四边等长）
  final int sideSeconds = 4; // 4-4-4-4
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: sideSeconds * 2), // 吸+呼共8秒
      vsync: this,
    );
  }
  
  void _startSession() {
    setState(() {
      currentPhase = Phase.inhale;
      currentCycle = 1;
      remainingSeconds = sideSeconds;
    });
    _animationController.forward(from: 0.0);
    _startPhase();
    HapticService.heavy();
  }
  
  void _startPhase() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });
      
      if (remainingSeconds <= 0) {
        _nextPhase();
      } else {
        HapticService.light();
      }
    });
  }
  
  void _nextPhase() {
    switch (currentPhase) {
      case Phase.inhale:
        setState(() {
          currentPhase = Phase.hold1;
          remainingSeconds = sideSeconds;
        });
        HapticService.medium();
        break;
      case Phase.hold1:
        setState(() {
          currentPhase = Phase.exhale;
          remainingSeconds = sideSeconds;
        });
        _animationController.reverse(from: 1.0);
        HapticService.medium();
        break;
      case Phase.exhale:
        setState(() {
          currentPhase = Phase.hold2;
          remainingSeconds = sideSeconds;
        });
        HapticService.medium();
        break;
      case Phase.hold2:
        if (currentCycle < totalCycles) {
          setState(() {
            currentCycle++;
            currentPhase = Phase.inhale;
            remainingSeconds = sideSeconds;
          });
          _animationController.forward(from: 0.0);
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
              const Text('⬜', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                '训练完成',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '完成了 $totalCycles 个箱式呼吸循环',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '保持这种专注和冷静的状态',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.accentAmber,
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
                    color: AppTheme.accentAmber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
    _animationController.dispose();
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
                  
                  // 箱式呼吸方块动画
                  _buildBoxAnimation(),
                  
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
            '箱式呼吸',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          // 循环数选择
          if (currentPhase == Phase.idle)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: totalCycles,
                  dropdownColor: AppTheme.secondaryDark,
                  style: const TextStyle(fontSize: 14),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: [5, 10, 15, 20].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value轮'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        totalCycles = value;
                      });
                    }
                  },
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildCycleIndicator() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: List.generate(totalCycles, (index) {
        final isCompleted = index < currentCycle - 1;
        final isCurrent = index == currentCycle - 1;
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.accentAmber
                : isCurrent
                    ? AppTheme.accentAmber.withOpacity(0.5)
                    : AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
  
  Widget _buildBoxAnimation() {
    final phaseColor = currentPhase == Phase.idle
        ? AppTheme.accentAmber.withOpacity(0.3)
        : AppTheme.accentAmber;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // 计算当前在方块路径上的位置
        double progress = 0.0;
        if (currentPhase == Phase.inhale) {
          progress = (sideSeconds - remainingSeconds) / sideSeconds * 0.25;
        } else if (currentPhase == Phase.hold1) {
          progress = 0.25 + (sideSeconds - remainingSeconds) / sideSeconds * 0.25;
        } else if (currentPhase == Phase.exhale) {
          progress = 0.5 + (sideSeconds - remainingSeconds) / sideSeconds * 0.25;
        } else if (currentPhase == Phase.hold2) {
          progress = 0.75 + (sideSeconds - remainingSeconds) / sideSeconds * 0.25;
        }
        
        // 圆形大小随呼吸变化
        final circleSize = currentPhase == Phase.idle
            ? 150.0
            : 150.0 + (_animationController.value * 80);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // 方块路径（装饰性）
            if (currentPhase != Phase.idle)
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: BoxPathPainter(
                    progress: progress,
                    color: phaseColor.withOpacity(0.3),
                  ),
                ),
              ),
            
            // 呼吸球
            Container(
              width: circleSize,
              height: circleSize,
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
                  currentPhase == Phase.idle ? '⬜' : _getPhaseEmoji(),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            
            // 阶段标签
            if (currentPhase != Phase.idle)
              Positioned(
                bottom: -40,
                child: Row(
                  children: [
                    _buildPhaseDot('吸', Phase.inhale),
                    const SizedBox(width: 8),
                    _buildPhaseDot('停', Phase.hold1),
                    const SizedBox(width: 8),
                    _buildPhaseDot('呼', Phase.exhale),
                    const SizedBox(width: 8),
                    _buildPhaseDot('停', Phase.hold2),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildPhaseDot(String label, Phase phase) {
    final isActive = currentPhase == phase;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentAmber
            : AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black : AppTheme.textMuted,
        ),
      ),
    );
  }
  
  String _getPhaseEmoji() {
    switch (currentPhase) {
      case Phase.inhale:
        return '👃';
      case Phase.hold1:
      case Phase.hold2:
        return '😌';
      case Phase.exhale:
        return '💨';
      case Phase.idle:
        return '⬜';
    }
  }
  
  Widget _buildPhaseInfo() {
    final String phaseText;
    final String instruction;
    
    switch (currentPhase) {
      case Phase.inhale:
        phaseText = '吸气';
        instruction = '用鼻子吸气，数4秒';
        break;
      case Phase.hold1:
        phaseText = '屏息';
        instruction = '保持呼吸，数4秒';
        break;
      case Phase.exhale:
        phaseText = '呼气';
        instruction = '用嘴呼气，数4秒';
        break;
      case Phase.hold2:
        phaseText = '屏息';
        instruction = '再次保持，数4秒';
        break;
      case Phase.idle:
        phaseText = '准备';
        instruction = '坐直，放松肩膀';
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
                : AppTheme.accentAmber,
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
      ],
    );
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
                  color: AppTheme.accentAmber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '开始练习',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
            '箱式呼吸：吸4秒 → 停4秒 → 呼4秒 → 停4秒',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          Text(
            '海军海豹同款，提升专注与冷静',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 箱式呼吸路径绘制
class BoxPathPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  BoxPathPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.8,
    );
    
    // 绘制完整方框
    canvas.drawRect(rect, paint);
    
    // 绘制进度指示器
    final progressPaint = Paint()
      ..color = AppTheme.accentAmber
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final perimeter = (rect.width + rect.height) * 2;
    final currentDistance = perimeter * progress;
    
    // 从左上角开始，顺时针
    var remaining = currentDistance;
    
    // 上边
    if (remaining > 0) {
      final topLength = remaining > rect.width ? rect.width : remaining;
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.left + topLength, rect.top);
      remaining -= topLength;
    }
    
    // 右边
    if (remaining > 0) {
      final rightLength = remaining > rect.height ? rect.height : remaining;
      path.moveTo(rect.left + rect.width, rect.top);
      path.lineTo(rect.left + rect.width, rect.top + rightLength);
      remaining -= rightLength;
    }
    
    // 下边
    if (remaining > 0) {
      final bottomLength = remaining > rect.width ? rect.width : remaining;
      path.moveTo(rect.left + rect.width, rect.top + rect.height);
      path.lineTo(rect.left + rect.width - bottomLength, rect.top + rect.height);
      remaining -= bottomLength;
    }
    
    // 左边
    if (remaining > 0) {
      final leftLength = remaining > rect.height ? rect.height : remaining;
      path.moveTo(rect.left, rect.top + rect.height);
      path.lineTo(rect.left, rect.top + rect.height - leftLength);
    }
    
    canvas.drawPath(path, progressPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
