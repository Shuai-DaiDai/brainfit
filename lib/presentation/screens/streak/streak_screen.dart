import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'streak_service.dart';

/// Streak 连续打卡页面
class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  int currentStreak = 0;
  int longestStreak = 0;
  int freezeCount = 0;
  bool hasPracticedToday = false;
  int weeklyStreak = 0;
  
  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }
  
  void _loadStreakData() {
    setState(() {
      currentStreak = StreakService.currentStreak;
      longestStreak = StreakService.longestStreak;
      freezeCount = StreakService.streakFreezeCount;
      hasPracticedToday = StreakService.hasPracticedToday;
      weeklyStreak = StreakService.getWeeklyStreak();
    });
  }
  
  void _onPractice() async {
    final result = await StreakService.recordPractice();
    
    _loadStreakData();
    
    // 显示结果
    _showStreakResult(result);
  }
  
  void _showStreakResult(StreakResult result) {
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
              // 火焰动画效果
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.streakFlame,
                      AppTheme.streakFlame.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.streakFlame.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🔥',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                result.isStreakContinued ? '连续打卡成功！' : '新的开始',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.streakFlame.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '连续 ${result.streak} 天',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.streakFlame,
                    fontFamily: 'SF Mono',
                  ),
                ),
              ),
              if (result.milestone != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.coralGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🎉 里程碑达成：${result.milestone!.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '奖励：${result.milestone!.reward} 神经元币',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部栏
            SliverToBoxAdapter(
              child: _buildAppBar(),
            ),
            
            // 主内容
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 火焰和天数
                  _buildStreakHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // 今日打卡按钮
                  _buildPracticeButton(),
                  
                  const SizedBox(height: 24),
                  
                  // 统计卡片
                  _buildStatsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 本周进度
                  _buildWeeklyProgress(),
                  
                  const SizedBox(height: 24),
                  
                  // 里程碑
                  _buildMilestones(),
                  
                  const SizedBox(height: 24),
                  
                  // Streak Freeze
                  _buildStreakFreeze(),
                ]),
              ),
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
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
            '连续打卡',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildStreakHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.streakFlame.withOpacity(0.2),
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.streakFlame.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // 火焰图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.streakFlame,
                  AppTheme.streakFlame.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.streakFlame.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '$currentStreak',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: AppTheme.streakFlame,
              fontFamily: 'SF Mono',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '连续打卡天数',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.streakFlame.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '最长记录: $longestStreak 天',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.streakFlame,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPracticeButton() {
    final isCompleted = hasPracticedToday;
    
    return GestureDetector(
      onTap: isCompleted ? null : _onPractice,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isCompleted 
              ? AppTheme.accentGreen.withOpacity(0.2)
              : AppTheme.accentCoral,
          borderRadius: BorderRadius.circular(20),
          border: isCompleted
              ? Border.all(color: AppTheme.accentGreen)
              : null,
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.accentCoral.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.local_fire_department,
              size: 32,
              color: isCompleted ? AppTheme.accentGreen : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted ? '今日已打卡' : '今日打卡',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCompleted ? AppTheme.accentGreen : Colors.white,
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 4),
              Text(
                '完成一次练习即可打卡',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('本周打卡', '$weeklyStreak/7', '📅'),
          _buildStatItem('保护盾', '$freezeCount', '🛡️'),
          _buildStatItem('总天数', '${StreakService.streakHistory.length}', '✨'),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, String icon) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Mono',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyProgress() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final history = StreakService.streakHistory;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final isPracticed = history.contains(dateStr);
              final isToday = date.day == now.day;
              
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPracticed
                          ? AppTheme.accentCoral
                          : isToday
                              ? AppTheme.accentCoral.withOpacity(0.3)
                              : AppTheme.primaryDark,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppTheme.accentCoral, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isPracticed
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : isToday
                              ? const Icon(Icons.circle, color: AppTheme.accentCoral, size: 8)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['一', '二', '三', '四', '五', '六', '日'][index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? AppTheme.accentCoral : AppTheme.textMuted,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMilestones() {
    final milestones = [
      _MilestoneData(day: 3, title: '初出茅庐', isReached: currentStreak >= 3),
      _MilestoneData(day: 7, title: '一周坚持', isReached: currentStreak >= 7),
      _MilestoneData(day: 21, title: '习惯养成', isReached: currentStreak >= 21),
      _MilestoneData(day: 30, title: '月度达人', isReached: currentStreak >= 30),
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '里程碑',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.map((m) => _buildMilestoneItem(m)),
        ],
      ),
    );
  }
  
  Widget _buildMilestoneItem(_MilestoneData milestone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: milestone.isReached
                  ? AppTheme.accentCoral
                  : AppTheme.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: milestone.isReached
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${milestone.day}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              milestone.title,
              style: TextStyle(
                fontSize: 14,
                color: milestone.isReached
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
                fontWeight: milestone.isReached ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (milestone.isReached)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentCoral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '已达成',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.accentCoral,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStreakFreeze() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak Freeze',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '跳过一天不中断连续',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x$freezeCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '100 神经元币购买一个保护盾',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneData {
  final int day;
  final String title;
  final bool isReached;
  
  _MilestoneData({
    required this.day,
    required this.title,
    required this.isReached,
  });
}
