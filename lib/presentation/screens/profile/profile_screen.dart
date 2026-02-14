import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../features/rewards/reward_service.dart';
import '../../../features/streak/streak_service.dart';

/// 个人中心页面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '脑力运动员';
  int brainAge = 28;
  int chronologicalAge = 28;
  int balance = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  int totalPractices = 0;
  DateTime joinDate = DateTime(2026, 2, 14);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      balance = RewardService.balance;
      currentStreak = StreakService.currentStreak;
      longestStreak = StreakService.longestStreak;
      totalPractices = LocalStorageService.getSetting<int>('total_practices', defaultValue: 0) ?? 0;
      // TODO: 从存储加载更多数据
    });
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
            
            // 用户信息卡片
            SliverToBoxAdapter(
              child: _buildUserCard(),
            ),
            
            // 统计数据
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
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
            '个人中心',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // 编辑资料
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: const Center(
              child: Text(
                '🧠',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '加入 BrainFit 第 ${_daysSinceJoin()} 天',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUserStat('实际年龄', '$chronologicalAge岁'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildUserStat('脑力年龄', '$brainAge岁'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
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

  int _daysSinceJoin() {
    return DateTime.now().difference(joinDate).inDays + 1;
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的数据',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              icon: '🧬',
              label: '神经元币',
              value: '$balance',
              color: AppTheme.accentGold,
              onTap: () => context.push('/rewards'),
            ),
            _buildStatCard(
              icon: '🔥',
              label: '连续打卡',
              value: '$currentStreak天',
              color: AppTheme.streakFlame,
              onTap: () => context.push('/streak'),
            ),
            _buildStatCard(
              icon: '🏆',
              label: '最长记录',
              value: '$longestStreak天',
              color: AppTheme.accentCoral,
            ),
            _buildStatCard(
              icon: '🧘',
              label: '总练习次数',
              value: '$totalPractices次',
              color: AppTheme.accentGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
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
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能入口',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.self_improvement,
          label: '我的成就',
          color: AppTheme.accentGold,
          onTap: () {
            // 跳转到成就页面
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          label: '练习记录',
          color: AppTheme.accentBlue,
          onTap: () {
            // 跳转到记录页面
          },
        ),
        _buildMenuItem(
          icon: Icons.bar_chart,
          label: '数据统计',
          color: AppTheme.accentGreen,
          onTap: () => context.push('/weekly-report'),
        ),
        _buildMenuItem(
          icon: Icons.share,
          label: '邀请好友',
          color: AppTheme.accentCoral,
          onTap: () {
            // 分享功能
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          label: '通知设置',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.dark_mode_outlined,
          label: '深色模式',
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeColor: AppTheme.accentCoral,
          ),
        ),
        _buildSettingItem(
          icon: Icons.privacy_tip_outlined,
          label: '隐私设置',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.help_outline,
          label: '帮助与反馈',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.info_outline,
          label: '关于 BrainFit',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
