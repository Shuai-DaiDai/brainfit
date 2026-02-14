import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../features/streak/streak_service.dart';
import '../../../features/rewards/reward_service.dart';

/// 脑力周报页面
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  // 模拟数据（实际应该从数据库获取）
  int currentBrainAge = 32;
  int lastWeekBrainAge = 33;
  double improvement = 1.0;
  
  int screenTimeMinutes = 252; // 4.2小时
  int brainTrainingMinutes = 48; // 0.8小时
  
  List<int> attentionScores = [62, 65, 63, 68, 70, 67, 72];
  List<int> dailyPracticeMinutes = [5, 8, 0, 12, 10, 8, 5];
  
  int weeklyRank = 48; // 前48%
  int lastWeekRank = 54; // 上周前54%
  
  @override
  Widget build(BuildContext context) {
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekRange = '${DateFormat('M月d日').format(weekStart)} - ${DateFormat('M月d日').format(weekEnd)}';
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部栏
            SliverToBoxAdapter(
              child: _buildAppBar(weekRange),
            ),
            
            // 内容
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 脑力年龄趋势
                  _buildBrainAgeCard(),
                  
                  const SizedBox(height: 16),
                  
                  // 屏幕时间对比
                  _buildTimeComparisonCard(),
                  
                  const SizedBox(height: 16),
                  
                  // 注意力分数趋势
                  _buildAttentionChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 同龄人排名
                  _buildRankingCard(),
                  
                  const SizedBox(height: 16),
                  
                  // 本周洞察
                  _buildInsightCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 分享按钮
                  _buildShareButton(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar(String weekRange) {
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
          Column(
            children: [
              Text(
                '脑力周报',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                weekRange,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // 分享功能
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.share, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBrainAgeCard() {
    final hasImproved = currentBrainAge <= lastWeekBrainAge;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            hasImproved 
                ? AppTheme.accentGreen.withOpacity(0.2)
                : AppTheme.accentCoral.withOpacity(0.2),
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasImproved 
              ? AppTheme.accentGreen.withOpacity(0.3)
              : AppTheme.accentCoral.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '上周',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lastWeekBrainAge',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Mono',
                    ),
                  ),
                  const Text(
                    '岁',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      hasImproved ? Icons.arrow_downward : Icons.arrow_upward,
                      color: hasImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasImproved 
                            ? AppTheme.accentGreen.withOpacity(0.2)
                            : AppTheme.accentCoral.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasImproved ? '↓ $improvement' : '↑ $improvement',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '本周',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentBrainAge',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: hasImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
                      fontFamily: 'SF Mono',
                    ),
                  ),
                  const Text(
                    '岁',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasImproved 
                ? '太棒了！你的大脑年轻了 $improvement 岁'
                : '注意！你的大脑老化了 $improvement 岁',
            style: TextStyle(
              fontSize: 14,
              color: hasImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeComparisonCard() {
    final ratio = brainTrainingMinutes / math.max(1, screenTimeMinutes);
    
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
            '屏幕时间 vs 健脑时间',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 屏幕时间
          _buildTimeBar(
            icon: '📱',
            label: '短视频/屏幕',
            minutes: screenTimeMinutes,
            color: AppTheme.textMuted,
            maxMinutes: screenTimeMinutes,
          ),
          
          const SizedBox(height: 16),
          
          // 健脑时间
          _buildTimeBar(
            icon: '🧠',
            label: '健脑练习',
            minutes: brainTrainingMinutes,
            color: AppTheme.accentGreen,
            maxMinutes: screenTimeMinutes,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '健脑时间仅为屏幕时间的 ${(ratio * 100).toInt()}%',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeBar({
    required String icon,
    required String label,
    required int minutes,
    required Color color,
    required int maxMinutes,
  }) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeString = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    final progress = minutes / math.max(1, maxMinutes);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primaryDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAttentionChart() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '注意力分数趋势',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '平均 ${(attentionScores.reduce((a, b) => a + b) / attentionScores.length).toInt()} 分',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.primaryDark,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['一', '二', '三', '四', '五', '六', '日'];
                        if (value >= 0 && value < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: attentionScores.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentCoral,
                        AppTheme.accentGreen,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.accentGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGreen.withOpacity(0.3),
                          AppTheme.accentGreen.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRankingCard() {
    final rankImproved = weeklyRank < lastWeekRank;
    
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
            '同龄人排名',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上周',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '前 $lastWeekRank%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                rankImproved ? Icons.arrow_forward : Icons.arrow_back,
                color: rankImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '本周',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '前 $weeklyRank%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: rankImproved ? AppTheme.accentGreen : AppTheme.accentCoral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '本周比 ${(100 - weeklyRank)}% 的同龄人更努力',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCoral.withOpacity(0.1),
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentCoral.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentCoral.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本周洞察',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '你的晚间健脑习惯正在形成，建议固定睡前练习时间以提升效果',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        // 生成分享卡片
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '分享我的脑力周报',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryDark,
                        AppTheme.secondaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('🧠', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        '本周脑力年龄',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentBrainAge 岁',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '比上周年轻了 $improvement 岁',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '#BrainFit #脑力健身房',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildShareOption('微信', Icons.wechat, Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShareOption('朋友圈', Icons.camera_alt, Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShareOption('保存', Icons.download, Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppTheme.coralGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '分享我的脑力周报',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildShareOption(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
