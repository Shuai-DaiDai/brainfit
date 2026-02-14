import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/rewards/reward_service.dart';

/// 奖励中心页面 - 神经元币余额和交易记录
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int balance = 0;
  int totalEarned = 0;
  int todayEarnings = 0;
  int weekEarnings = 0;
  List<CoinTransaction> transactions = [];
  bool canClaimDaily = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      balance = RewardService.balance;
      totalEarned = RewardService.totalEarned;
      todayEarnings = RewardService.getTodayEarnings();
      weekEarnings = RewardService.getWeekEarnings();
      transactions = RewardService.transactionHistory.take(20).toList();
      canClaimDaily = RewardService.canClaimDailyReward;
    });
  }

  Future<void> _claimDailyReward() async {
    final result = await RewardService.claimDailyReward();
    
    _loadData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppTheme.accentGreen : Colors.red,
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
            
            // 余额卡片
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),
            
            // 统计和签到
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 每日签到
                  if (canClaimDaily) _buildDailyRewardCard(),
                  if (canClaimDaily) const SizedBox(height: 16),
                  
                  // 统计
                  _buildStatsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 交易记录
                  _buildTransactionList(),
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
            '奖励中心',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGold.withOpacity(0.3),
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text('🧬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            '神经元币余额',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$balance',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
              fontFamily: 'SF Mono',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '累计赚取: $totalEarned',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewardCard() {
    return GestureDetector(
      onTap: _claimDailyReward,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🎁', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '每日签到奖励',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击领取 50+ 神经元币',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
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
          _buildStatItem('今日收入', '+$todayEarnings', '📅'),
          _buildStatItem('本周收入', '+$weekEarnings', '📊'),
          _buildStatItem('交易笔数', '${transactions.length}', '📝'),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentGold,
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

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近交易',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '暂无交易记录',
                style: TextStyle(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          )
        else
          ...transactions.map((t) => _buildTransactionItem(t)),
      ],
    );
  }

  Widget _buildTransactionItem(CoinTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? AppTheme.accentGreen.withOpacity(0.2)
                  : AppTheme.accentCoral.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.type.icon,
              color: transaction.isIncome
                  ? AppTheme.accentGreen
                  : AppTheme.accentCoral,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isIncome ? '+' : ''}${transaction.amount}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome
                  ? AppTheme.accentGreen
                  : AppTheme.accentCoral,
              fontFamily: 'SF Mono',
            ),
          ),
        ],
      ),
    );
  }
}
