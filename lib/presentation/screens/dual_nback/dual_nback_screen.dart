import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Dual N-back 游戏 - 脑力竞技场
/// 工作记忆训练的金标准
class DualNBackScreen extends StatefulWidget {
  const DualNBackScreen({super.key});

  @override
  State<DualNBackScreen> createState() => _DualNBackScreenState();
}

class _DualNBackScreenState extends State<DualNBackScreen> {
  // 游戏配置
  int nLevel = 2; // 当前N等级
  int score = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int missedCount = 0;
  
  // 游戏状态
  bool isPlaying = false;
  bool isPaused = false;
  int currentTrial = 0;
  static const int totalTrials = 20; // 每局20个试次
  
  // 刺激序列
  List<int> positionHistory = [];
  List<int> soundHistory = [];
  
  // 当前刺激
  int currentPosition = -1;
  int currentSound = -1;
  
  // 用户响应
  bool positionMatched = false;
  bool soundMatched = false;
  
  // 动画和反馈
  bool showFeedback = false;
  bool? lastPositionCorrect;
  bool? lastSoundCorrect;
  
  Timer? stimulusTimer;
  Timer? responseTimer;
  
  // 响应窗口
  static const int stimulusDurationMs = 3000;
  static const int responseWindowMs = 1500;
  
  // 声音提示（用数字1-8代替）
  final List<String> soundNames = ['Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Ti', 'Do'];

  @override
  void initState() {
    super.initState();
    _generateSequences();
  }
  
  void _generateSequences() {
    final random = math.Random();
    positionHistory = [];
    soundHistory = [];
    
    // 生成位置序列（0-8对应3x3网格）
    for (int i = 0; i < totalTrials; i++) {
      // 30%概率匹配N-back
      if (i >= nLevel && random.nextDouble() < 0.3) {
        positionHistory.add(positionHistory[i - nLevel]);
      } else {
        positionHistory.add(random.nextInt(9));
      }
      
      // 30%概率声音匹配
      if (i >= nLevel && random.nextDouble() < 0.3) {
        soundHistory.add(soundHistory[i - nLevel]);
      } else {
        soundHistory.add(random.nextInt(8));
      }
    }
  }
  
  void _startGame() {
    setState(() {
      isPlaying = true;
      isPaused = false;
      currentTrial = 0;
      score = 0;
      correctCount = 0;
      wrongCount = 0;
      missedCount = 0;
    });
    
    _generateSequences();
    _nextTrial();
  }
  
  void _nextTrial() {
    if (currentTrial >= totalTrials) {
      _endGame();
      return;
    }
    
    setState(() {
      currentPosition = positionHistory[currentTrial];
      currentSound = soundHistory[currentTrial];
      positionMatched = false;
      soundMatched = false;
      showFeedback = false;
    });
    
    // 播放声音（视觉提示）
    HapticFeedback.lightImpact();
    
    // 响应窗口
    responseTimer = Timer(const Duration(milliseconds: responseWindowMs), () {
      _checkMissedMatches();
    });
    
    // 下一个刺激
    stimulusTimer = Timer(const Duration(milliseconds: stimulusDurationMs), () {
      responseTimer?.cancel();
      setState(() {
        currentTrial++;
        currentPosition = -1;
        currentSound = -1;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && isPlaying) {
          _nextTrial();
        }
      });
    });
  }
  
  void _onPositionMatch() {
    if (!isPlaying || positionMatched) return;
    
    setState(() {
      positionMatched = true;
    });
    
    // 检查是否正确
    final shouldMatch = currentTrial >= nLevel &&
        positionHistory[currentTrial] == positionHistory[currentTrial - nLevel];
    
    if (shouldMatch) {
      score += 10;
      correctCount++;
      setState(() => lastPositionCorrect = true);
      HapticFeedback.lightImpact();
    } else {
      score -= 5;
      wrongCount++;
      setState(() => lastPositionCorrect = false);
      HapticFeedback.vibrate();
    }
    
    _showFeedback();
  }
  
  void _onSoundMatch() {
    if (!isPlaying || soundMatched) return;
    
    setState(() {
      soundMatched = true;
    });
    
    // 检查是否正确
    final shouldMatch = currentTrial >= nLevel &&
        soundHistory[currentTrial] == soundHistory[currentTrial - nLevel];
    
    if (shouldMatch) {
      score += 10;
      correctCount++;
      setState(() => lastSoundCorrect = true);
      HapticFeedback.lightImpact();
    } else {
      score -= 5;
      wrongCount++;
      setState(() => lastSoundCorrect = false);
      HapticFeedback.vibrate();
    }
    
    _showFeedback();
  }
  
  void _checkMissedMatches() {
    // 检查错过的匹配
    final shouldPositionMatch = currentTrial >= nLevel &&
        positionHistory[currentTrial] == positionHistory[currentTrial - nLevel];
    final shouldSoundMatch = currentTrial >= nLevel &&
        soundHistory[currentTrial] == soundHistory[currentTrial - nLevel];
    
    if (shouldPositionMatch && !positionMatched) {
      missedCount++;
    }
    if (shouldSoundMatch && !soundMatched) {
      missedCount++;
    }
  }
  
  void _showFeedback() {
    setState(() => showFeedback = true);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
          lastPositionCorrect = null;
          lastSoundCorrect = null;
        });
      }
    });
  }
  
  void _pauseGame() {
    setState(() => isPaused = true);
    stimulusTimer?.cancel();
    responseTimer?.cancel();
  }
  
  void _resumeGame() {
    setState(() => isPaused = false);
    _nextTrial();
  }
  
  void _endGame() {
    setState(() => isPlaying = false);
    stimulusTimer?.cancel();
    responseTimer?.cancel();
    
    HapticFeedback.heavyImpact();
    
    // 升级检测
    final accuracy = (correctCount / (correctCount + wrongCount + missedCount)) * 100;
    if (accuracy >= 80 && correctCount >= 10) {
      // 可以升级
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildResultDialog(),
    );
  }
  
  @override
  void dispose() {
    stimulusTimer?.cancel();
    responseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: isPlaying ? _buildGameScreen() : _buildStartScreen(),
      ),
    );
  }
  
  Widget _buildStartScreen() {
    return Column(
      children: [
        // 顶部栏
        Padding(
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
                '脑力竞技场',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 星球图标
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.8),
                        Colors.red.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🪐', style: TextStyle(fontSize: 56)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Level $nLevel - ${_getPlanetName()}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '$nLevel-back 工作记忆训练',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
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
                    children: [
                      _buildInstructionRow('🟦', '位置和N个之前相同，点位置匹配'),
                      const SizedBox(height: 12),
                      _buildInstructionRow('🔊', '声音和N个之前相同，点声音匹配'),
                      const SizedBox(height: 12),
                      _buildInstructionRow('⚡', '快速反应，提高工作记忆'),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // 开始按钮
                GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '开始挑战',
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
  
  Widget _buildInstructionRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getPlanetName() {
    final planets = ['水星', '金星', '地球', '火星', '木星', '土星', '天王星', '海王星'];
    return planets[(nLevel - 1) % planets.length];
  }
  
  Widget _buildGameScreen() {
    final progress = currentTrial / totalTrials;
    
    return Column(
      children: [
        // 顶部状态栏
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Mono',
                ),
              ),
              Text(
                '${currentTrial + 1}/$totalTrials',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // 进度条
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.secondaryDark,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          minHeight: 6,
        ),
        
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3x3 网格
              Container(
                width: 280,
                height: 280,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final isActive = index == currentPosition;
                    final isMatched = positionMatched && isActive;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.orange
                            : AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(8),
                        border: showFeedback && isActive
                            ? Border.all(
                                color: lastPositionCorrect == true
                                    ? Colors.green
                                    : Colors.red,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isActive
                          ? Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 当前声音提示
              if (currentSound >= 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        soundNames[currentSound],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // 匹配按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMatchButton(
                    label: '位置匹配',
                    icon: Icons.grid_on,
                    color: Colors.blue,
                    onTap: _onPositionMatch,
                    isPressed: positionMatched,
                    isCorrect: lastPositionCorrect,
                  ),
                  const SizedBox(width: 24),
                  _buildMatchButton(
                    label: '声音匹配',
                    icon: Icons.volume_up,
                    color: Colors.green,
                    onTap: _onSoundMatch,
                    isPressed: soundMatched,
                    isCorrect: lastSoundCorrect,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 底部提示
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '记住 ${nLevel}个位置前的方块和声音',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMatchButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isPressed,
    required bool? isCorrect,
  }) {
    Color bgColor = color.withOpacity(0.2);
    Color borderColor = color.withOpacity(0.5);
    
    if (isPressed) {
      if (isCorrect == true) {
        bgColor = Colors.green.withOpacity(0.3);
        borderColor = Colors.green;
      } else if (isCorrect == false) {
        bgColor = Colors.red.withOpacity(0.3);
        borderColor = Colors.red;
      }
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultDialog() {
    final accuracy = correctCount / math.max(1, correctCount + wrongCount + missedCount);
    final canLevelUp = accuracy >= 0.8 && correctCount >= 10;
    
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
            const Text('🎮', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '挑战完成！',
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
                  _buildResultRow('最终得分', '$score'),
                  const SizedBox(height: 12),
                  _buildResultRow('正确匹配', '$correctCount'),
                  const SizedBox(height: 12),
                  _buildResultRow('准确率', '${(accuracy * 100).toInt()}%'),
                ],
              ),
            ),
            if (canLevelUp) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.red],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🎉 可以升级到 Level ${nLevel + 1}！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.textMuted),
                      ),
                      child: const Center(
                        child: Text('返回'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (canLevelUp) {
                        setState(() => nLevel++);
                      }
                      _startGame();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.red],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          canLevelUp ? '升级挑战' : '再玩一次',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultRow(String label, String value) {
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
