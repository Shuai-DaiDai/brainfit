import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 正念冥想页面
/// L2 修复层核心功能
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  // 冥想场景
  final List<MeditationScene> scenes = [
    MeditationScene(
      id: 'forest',
      name: '静谧森林',
      description: '鸟鸣、风声、树叶沙沙',
      icon: '🌲',
      color: const Color(0xFF2D6A4F),
      gradient: const [Color(0xFF40916C), Color(0xFF2D6A4F)],
    ),
    MeditationScene(
      id: 'ocean',
      name: '深海冥想',
      description: '海浪、鲸鱼、水下宁静',
      icon: '🌊',
      color: const Color(0xFF0077B6),
      gradient: const [Color(0xFF00B4D8), Color(0xFF0077B6)],
    ),
    MeditationScene(
      id: 'space',
      name: '星空之旅',
      description: '宇宙、星辰、无限宁静',
      icon: '✨',
      color: const Color(0xFF3C096C),
      gradient: const [Color(0xFF5A189A), Color(0xFF3C096C)],
    ),
    MeditationScene(
      id: 'rain',
      name: '雨声安眠',
      description: '雨滴、雷声、室内温暖',
      icon: '🌧️',
      color: const Color(0xFF495057),
      gradient: const [Color(0xFF6C757D), Color(0xFF495057)],
    ),
  ];
  
  int selectedSceneIndex = 0;
  int selectedDuration = 5; // 默认5分钟
  
  bool isMeditating = false;
  bool isPaused = false;
  int remainingSeconds = 0;
  int totalSeconds = 0;
  
  // 走神检测
  int checkInCount = 0;
  int focusScore = 100;
  DateTime? meditationStartTime;
  
  Timer? timer;
  Timer? checkInTimer;
  
  // 呼吸动画
  late AnimationController _breathController;
  
  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 8), //  slower breathing for meditation
      vsync: this,
    );
  }
  
  void _startMeditation() {
    setState(() {
      isMeditating = true;
      totalSeconds = selectedDuration * 60;
      remainingSeconds = totalSeconds;
      checkInCount = 0;
      focusScore = 100;
      meditationStartTime = DateTime.now();
    });
    
    HapticFeedback.mediumImpact();
    _breathController.repeat(reverse: true);
    
    // 主计时器
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _completeMeditation();
        }
      });
    });
    
    // 走神检测（随机间隔弹出）
    _scheduleCheckIn();
  }
  
  void _scheduleCheckIn() {
    // 随机 30-90 秒后弹出检测
    final delay = 30 + math.Random().nextInt(60);
    checkInTimer = Timer(Duration(seconds: delay), () {
      if (isMeditating && !isPaused && mounted) {
        _showCheckInDialog();
      }
    });
  }
  
  void _showCheckInDialog() {
    timer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                '走神检测',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '点击确认你还在专注冥想',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  checkInCount++;
                  timer = Timer.periodic(const Duration(seconds: 1), (t) {
                    setState(() {
                      if (remainingSeconds > 0) {
                        remainingSeconds--;
                      } else {
                        _completeMeditation();
                      }
                    });
                  });
                  _scheduleCheckIn();
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
                      '我还在这里',
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
  
  void _pauseMeditation() {
    setState(() => isPaused = true);
    _breathController.stop();
    timer?.cancel();
    checkInTimer?.cancel();
  }
  
  void _resumeMeditation() {
    setState(() => isPaused = false);
    _breathController.repeat(reverse: true);
    
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _completeMeditation();
        }
      });
    });
    
    _scheduleCheckIn();
  }
  
  void _completeMeditation() {
    timer?.cancel();
    checkInTimer?.cancel();
    _breathController.stop();
    
    // 计算专注度
    final totalCheckIns = (totalSeconds ~/ 60); // 预期检测次数
    focusScore = ((checkInCount / totalCheckIns) * 100).toInt().clamp(50, 100);
    
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }
  
  @override
  void dispose() {
    timer?.cancel();
    checkInTimer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: isMeditating ? _buildActiveMeditation() : _buildSetupView(),
      ),
    );
  }
  
  Widget _buildSetupView() {
    final selectedScene = scenes[selectedSceneIndex];
    
    return Column(
      children: [
        // 顶部栏
        _buildAppBar(),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 场景选择
                Text(
                  '选择冥想场景',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: scenes.length,
                    itemBuilder: (context, index) {
                      final scene = scenes[index];
                      final isSelected = index == selectedSceneIndex;
                      
                      return GestureDetector(
                        onTap: () => setState(() => selectedSceneIndex = index),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: scene.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: scene.color.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(scene.icon, style: const TextStyle(fontSize: 32)),
                                const Spacer(),
                                Text(
                                  scene.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scene.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 时长选择
                Text(
                  '选择时长',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [3, 5, 10, 15, 20].map((minutes) {
                    final isSelected = selectedDuration == minutes;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDuration = minutes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? selectedScene.color : AppTheme.secondaryDark,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: selectedScene.color, width: 2)
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
                
                const SizedBox(height: 32),
                
                // 说明
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '冥想提示',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• 找一个安静舒适的地方\n'
                        '• 闭上眼睛，跟随呼吸\n'
                        '• 思绪飘走时温柔地拉回\n'
                        '• 结束后慢慢睁开眼睛',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 开始按钮
                GestureDetector(
                  onTap: _startMeditation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selectedScene.gradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: selectedScene.color.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '开始冥想',
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
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const Spacer(),
          Text(
            '正念冥想',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildActiveMeditation() {
    final scene = scenes[selectedSceneIndex];
    final progress = 1 - (remainingSeconds / totalSeconds);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scene.gradient[0].withOpacity(0.3),
            AppTheme.primaryDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 顶部栏
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _pauseMeditation();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.secondaryDark,
                        title: const Text('结束冥想？'),
                        content: const Text('你的进度将不会被保存'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _resumeMeditation();
                            },
                            child: const Text('继续'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('结束', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                Text(
                  scene.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          
          // 进度条
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(scene.color),
            minHeight: 4,
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 呼吸球
                AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, child) {
                    final scale = 0.6 + (_breathController.value * 0.4);
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            scene.color.withOpacity(0.8),
                            scene.color.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 180 * scale,
                          height: 180 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                scene.color,
                                scene.color.withOpacity(0.5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scene.color.withOpacity(0.5),
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
                
                const SizedBox(height: 48),
                
                // 倒计时
                Text(
                  '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Mono',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 提示文字
                AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, child) {
                    final phase = _breathController.value < 0.5 ? '吸气' : '呼气';
                    return Text(
                      phase,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // 控制按钮
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isPaused ? _resumeMeditation : _pauseMeditation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletionDialog() {
    final scene = scenes[selectedSceneIndex];
    final duration = totalSeconds ~/ 60;
    
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
            Text(scene.icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '冥想完成',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildResultRow('冥想时长', '$duration 分钟'),
                  const SizedBox(height: 12),
                  _buildResultRow('走神检测', '$checkInCount 次'),
                  const SizedBox(height: 12),
                  _buildResultRow('专注度', '$focusScore%', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: scene.gradient),
                borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 4),
                  Text(
                    '🧬 ${duration * 10 + focusScore ~/ 10}',
                    style: const TextStyle(
                      fontSize: 32,
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
                  color: scene.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
  
  Widget _buildResultRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppTheme.accentGreen : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 冥想场景
class MeditationScene {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final List<Color> gradient;
  
  MeditationScene({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
