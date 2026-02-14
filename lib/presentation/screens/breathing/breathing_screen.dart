import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// 呼吸练习主页 - 整合所有呼吸练习类型
class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  final List<BreathingMethod> methods = const [
    BreathingMethod(
      id: 'resonant',
      name: '共振呼吸',
      description: '5.5秒周期，最大化HRV，快速平静',
      icon: '🌊',
      color: Color(0xFF4ECDC4),
      duration: '2-15分钟',
      benefit: '降低心率、减轻压力',
    ),
    BreathingMethod(
      id: 'cyclic_sighing',
      name: '循环叹息',
      description: '双吸+长呼，斯坦福验证减压法',
      icon: '🍃',
      color: Color(0xFF2A9D8F),
      duration: '1-5分钟',
      benefit: '60秒显著降低应激',
    ),
    BreathingMethod(
      id: 'four_seven_eight',
      name: '4-7-8呼吸',
      description: '经典放松呼吸法，助眠神器',
      icon: '🌙',
      color: Color(0xFF9B5DE5),
      duration: '4-12分钟',
      benefit: '快速入睡、深度放松',
    ),
    BreathingMethod(
      id: 'box',
      name: '箱式呼吸',
      description: '海军海豹同款，提升专注和冷静',
      icon: '⬜',
      color: Color(0xFFF4A261),
      duration: '3-10分钟',
      benefit: '提升专注、压力管理',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部栏
            SliverToBoxAdapter(
              child: _buildAppBar(context),
            ),
            
            // 今日推荐
            SliverToBoxAdapter(
              child: _buildTodayRecommendation(context),
            ),
            
            // 所有呼吸方法
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    '选择呼吸方法',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...methods.map((method) => _buildMethodCard(context, method)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
            '呼吸练习',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTodayRecommendation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.3),
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌊', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '今日推荐',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '共振呼吸',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '5.5秒呼吸周期，最大化HRV，快速激活副交感神经，90秒即可感受效果',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag('⏱️ 2分钟', const Color(0xFF4ECDC4)),
              const SizedBox(width: 8),
              _buildTag('💚 减压', const Color(0xFF4ECDC4)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/breathing/resonant'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '开始练习',
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
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMethodCard(BuildContext context, BreathingMethod method) {
    return GestureDetector(
      onTap: () {
        switch (method.id) {
          case 'resonant':
            context.push('/breathing/resonant');
            break;
          case 'cyclic_sighing':
            context.push('/breathing/cyclic-sighing');
            break;
          case 'four_seven_eight':
            context.push('/breathing/four-seven-eight');
            break;
          case 'box':
            context.push('/breathing/box');
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: method.color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                method.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${method.duration} · ${method.benefit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: method.color,
                    ),
                  ),
                ],
              ),
    ),
            Icon(
              Icons.arrow_forward_ios,
              color: method.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('即将上线'),
        content: const Text('该功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class BreathingMethod {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final String duration;
  final String benefit;

  const BreathingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
    required this.benefit,
  });
}
