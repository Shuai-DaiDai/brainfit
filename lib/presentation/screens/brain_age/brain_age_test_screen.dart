import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/brain_age_test.dart';
import 'tests/attention_span_test.dart';
import 'tests/working_memory_test.dart';
import 'tests/reaction_speed_test.dart';

/// 完整的脑力年龄测试流程
class BrainAgeTestScreen extends StatefulWidget {
  const BrainAgeTestScreen({super.key});

  @override
  State<BrainAgeTestScreen> createState() => _BrainAgeTestScreenState();
}

class _BrainAgeTestScreenState extends State<BrainAgeTestScreen> {
  int currentStep = 0; // 0=介绍, 1=注意力测试, 2=记忆测试, 3=反应测试, 4=计算中, 5=结果
  
  // 测试结果
  int attentionScore = 0;
  int memoryScore = 0;
  int reactionScore = 0;
  
  int attentionTimeMs = 0;
  int attentionErrors = 0;
  
  int memoryNLevel = 2;
  double memoryAccuracy = 0;
  int memoryReactionTime = 0;
  
  int reactionTimeMs = 0;
  int reactionAccuracy = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildIntroScreen();
      case 1:
        return AttentionSpanTest(
          onComplete: (score, timeMs, errors) {
            setState(() {
              attentionScore = score;
              attentionTimeMs = timeMs;
              attentionErrors = errors;
              currentStep = 2;
            });
          },
        );
      case 2:
        return WorkingMemoryTest(
          onComplete: (score, nLevel, accuracy, avgReactionTime) {
            setState(() {
              memoryScore = score;
              memoryNLevel = nLevel;
              memoryAccuracy = accuracy;
              memoryReactionTime = avgReactionTime;
              currentStep = 3;
            });
          },
        );
      case 3:
        return ReactionSpeedTest(
          onComplete: (score, avgReactionTime, accuracy) {
            setState(() {
              reactionScore = score;
              reactionTimeMs = avgReactionTime;
              reactionAccuracy = accuracy;
              currentStep = 4;
            });
            // 延迟后显示结果
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                currentStep = 5;
              });
            });
          },
        );
      case 4:
        return _buildCalculatingScreen();
      case 5:
        return _buildResultScreen();
      default:
        return _buildIntroScreen();
    }
  }
  
  Widget _buildIntroScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部栏
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
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
          ],
        ),
        
        const SizedBox(height: 32),
        
        // 标题
        const Text('🧠', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          '脑力年龄测试',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          '3分钟了解你的大脑真实状态',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 测试说明
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '测试包含三个维度：',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTestItem(
                  icon: '👁️',
                  title: '注意力广度',
                  description: '按顺序点击数字 1-25',
                  duration: '约 30-60 秒',
                ),
                const SizedBox(height: 16),
                _buildTestItem(
                  icon: '🧩',
                  title: '工作记忆',
                  description: '2-back 记忆匹配游戏',
                  duration: '约 60 秒',
                ),
                const SizedBox(height: 16),
                _buildTestItem(
                  icon: '⚡',
                  title: '反应速度',
                  description: '看到红色/黄色立即点击',
                  duration: '约 45 秒',
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 开始按钮
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              currentStep = 1;
            });
          },
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
                '开始测试',
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
    );
  }
  
  Widget _buildTestItem({
    required String icon,
    required String title,
    required String description,
    required String duration,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalculatingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '正在分析你的大脑数据...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            '对比 ${attentionScore + memoryScore + reactionScore} 个数据点',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultScreen() {
    // 计算综合分数和脑力年龄
    final averageScore = (attentionScore + memoryScore + reactionScore) ~/ 3;
    
    // 获取用户实际年龄（这里用默认值，实际应该从用户资料获取）
    final chronologicalAge = 28;
    
    // 计算脑力年龄
    final brainAge = _calculateBrainAge(chronologicalAge, averageScore);
    final brainAgeDelta = brainAge - chronologicalAge;
    
    // 保存结果
    _saveResult(brainAge, brainAgeDelta, averageScore);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Center(
            child: Column(
              children: [
                const Text('📊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '测试结果',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 年龄对比
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAgeDisplay(
                      label: '实际年龄',
                      age: chronologicalAge,
                      color: AppTheme.textPrimary,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppTheme.textMuted,
                        size: 32,
                      ),
                    ),
                    _buildAgeDisplay(
                      label: '脑力年龄',
                      age: brainAge,
                      color: brainAgeDelta > 0 ? AppTheme.accentCoral : AppTheme.accentGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: brainAgeDelta > 0
                        ? AppTheme.accentCoral.withOpacity(0.1)
                        : AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    brainAgeDelta > 0
                        ? '你的大脑比你老了 $brainAgeDelta 岁'
                        : '你的大脑比实际年轻 ${brainAgeDelta.abs()} 岁',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: brainAgeDelta > 0 ? AppTheme.accentCoral : AppTheme.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 分项得分
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '各项得分',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildScoreRow('注意力广度', attentionScore),
                const SizedBox(height: 12),
                _buildScoreRow('工作记忆', memoryScore),
                const SizedBox(height: 12),
                _buildScoreRow('反应速度', reactionScore),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 希望消息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen.withOpacity(0.2),
                  AppTheme.accentGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '好消息：90% 的用户在 21 天内平均年轻 3 岁',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // CTA 按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              LocalStorageService.hasTakenBrainAgeTest = true;
              context.go('/home');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '开始我的健脑之旅',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 重新测试按钮
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  currentStep = 0;
                  attentionScore = 0;
                  memoryScore = 0;
                  reactionScore = 0;
                });
              },
              child: Text(
                '重新测试',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgeDisplay({
    required String label,
    required int age,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$age',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'SF Mono',
          ),
        ),
        Text(
          '岁',
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildScoreRow(String label, int score) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: score >= 80
                      ? [AppTheme.accentGreen, AppTheme.accentGreen.withOpacity(0.8)]
                      : score >= 60
                          ? [AppTheme.accentCoral, AppTheme.accentCoral.withOpacity(0.8)]
                          : [AppTheme.textMuted, AppTheme.textMuted.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: score >= 80
                ? AppTheme.accentGreen
                : score >= 60
                    ? AppTheme.accentCoral
                    : AppTheme.textMuted,
            fontFamily: 'SF Mono',
          ),
        ),
      ],
    );
  }
  
  int _calculateBrainAge(int chronologicalAge, int averageScore) {
    // 算法：50分对应实际年龄，每高10分减2岁，每低10分加2岁
    final deviation = (averageScore - 50) / 10 * 2;
    final calculated = chronologicalAge - deviation.round();
    return calculated.clamp(18, 80);
  }
  
  void _saveResult(int brainAge, int delta, int averageScore) {
    // TODO: 保存到本地存储和 Firebase
    final result = BrainAgeTest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      completedAt: DateTime.now(),
      attentionScore: attentionScore,
      memoryScore: memoryScore,
      reactionScore: reactionScore,
      chronologicalAge: 28, // TODO: 从用户资料获取
      brainAge: brainAge,
      brainAgeDelta: delta,
    );
    
    LocalStorageService.saveBrainAgeTest(result);
  }
}
