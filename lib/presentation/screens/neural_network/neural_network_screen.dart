import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/local_storage_service.dart';

/// 神经网络地图页面
/// 用户成长可视化 - 点亮脑区
class NeuralNetworkScreen extends StatefulWidget {
  const NeuralNetworkScreen({super.key});

  @override
  State<NeuralNetworkScreen> createState() => _NeuralNetworkScreenState();
}

class _NeuralNetworkScreenState extends State<NeuralNetworkScreen>
    with TickerProviderStateMixin {
  
  // 四个脑区
  final List<BrainRegion> regions = [
    BrainRegion(
      id: 'frontal',
      name: '前额叶',
      function: '注意力',
      description: '负责专注、决策、自控',
      icon: '🎯',
      color: const Color(0xFF4ECDC4),
      position: const Offset(0, -1), // 顶部
      totalLevels: 10,
    ),
    BrainRegion(
      id: 'limbic',
      name: '边缘系统',
      function: '情绪',
      description: '调节情绪、压力反应',
      icon: '❤️',
      color: const Color(0xFFF4A261),
      position: const Offset(-1, 0), // 左侧
      totalLevels: 10,
    ),
    BrainRegion(
      id: 'hippocampus',
      name: '海马体',
      function: '记忆',
      description: '工作记忆、学习新知',
      icon: '🧩',
      color: const Color(0xFF9B5DE5),
      position: const Offset(1, 0), // 右侧
      totalLevels: 10,
    ),
    BrainRegion(
      id: 'cingulate',
      name: '前扣带皮层',
      function: '习惯',
      description: '形成习惯、自动行为',
      icon: '🔄',
      color: const Color(0xFF00BBF9),
      position: const Offset(0, 1), // 底部
      totalLevels: 10,
    ),
  ];
  
  // 当前选中的脑区
  String? selectedRegionId;
  
  // 动画控制器
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _loadProgress();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  void _loadProgress() {
    // 从本地存储加载进度（简化实现）
    for (var region in regions) {
      final savedLevel = LocalStorageService.getSetting<int>(
        'region_${region.id}_level',
        defaultValue: 0,
      );
      region.currentLevel = savedLevel ?? 0;
    }
  }
  
  void _saveProgress(String regionId, int level) {
    LocalStorageService.setSetting('region_${regionId}_level', level);
  }
  
  void _onRegionTap(String regionId) {
    setState(() {
      selectedRegionId = selectedRegionId == regionId ? null : regionId;
    });
    HapticFeedback.lightImpact();
  }
  
  void _upgradeRegion(String regionId) {
    final region = regions.firstWhere((r) => r.id == regionId);
    if (region.currentLevel < region.totalLevels) {
      setState(() {
        region.currentLevel++;
      });
      _saveProgress(regionId, region.currentLevel);
      HapticFeedback.heavyImpact();
      
      // 显示升级动画
      _showUpgradeAnimation(region);
    }
  }
  
  void _showUpgradeAnimation(BrainRegion region) {
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
              // 光芒动画
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Container(
                    width: 100 + (50 * value),
                    height: 100 + (50 * value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          region.color.withOpacity(1 - value),
                          region.color.withOpacity(0),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        region.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                '${region.name} 升级！',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${region.currentLevel}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: region.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                region.currentLevel == region.totalLevels
                    ? '该脑区已完全激活！'
                    : '再完成 ${region.totalLevels - region.currentLevel} 次训练可继续升级',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: region.color,
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
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalProgress = regions.fold<double>(0, (sum, r) => sum + r.progress) / regions.length;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            _buildAppBar(totalProgress),
            
            // 神经网络地图
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 连接线
                  CustomPaint(
                    size: Size.infinite,
                    painter: NeuralConnectionPainter(
                      regions: regions,
                      progress: totalProgress,
                    ),
                  ),
                  
                  // 脑区节点
                  ...regions.map((region) => _buildRegionNode(region)),
                  
                  // 选中详情
                  if (selectedRegionId != null)
                    _buildRegionDetail(
                      regions.firstWhere((r) => r.id == selectedRegionId),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar(double totalProgress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const Spacer(),
              Text(
                '神经网络',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          // 总进度
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '神经网络进度',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${(totalProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    backgroundColor: AppTheme.primaryDark,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '已激活 ${regions.where((r) => r.currentLevel > 0).length}/${regions.length} 个脑区',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegionNode(BrainRegion region) {
    final isSelected = selectedRegionId == region.id;
    final isUnlocked = region.currentLevel > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height - 200;
    
    // 计算位置（基于屏幕中心的偏移）
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    final offsetX = region.position.dx * 120;
    final offsetY = region.position.dy * 120;
    
    return Positioned(
      left: centerX + offsetX - 50,
      top: centerY + offsetY - 50,
      child: GestureDetector(
        onTap: () => _onRegionTap(region.id),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = isUnlocked 
                ? 1.0 + (_pulseController.value * 0.05)
                : 1.0;
            
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked 
                      ? region.color.withOpacity(0.2)
                      : AppTheme.secondaryDark,
                  border: Border.all(
                    color: isUnlocked 
                        ? region.color
                        : isSelected
                            ? region.color.withOpacity(0.5)
                            : AppTheme.textMuted.withOpacity(0.3),
                    width: isUnlocked ? 3 : (isSelected ? 2 : 1),
                    style: isUnlocked 
                        ? BorderStyle.solid 
                        : (isSelected ? BorderStyle.solid : BorderStyle.dashed),
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: region.color.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      region.icon,
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? null : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      region.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? region.color : AppTheme.textMuted,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Lv.${region.currentLevel}',
                        style: TextStyle(
                          fontSize: 10,
                          color: region.color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildRegionDetail(BrainRegion region) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: region.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: region.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(region.icon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '功能: ${region.function}',
                        style: TextStyle(
                          fontSize: 14,
                          color: region.color,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => selectedRegionId = null),
                  child: const Icon(Icons.close, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              region.description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // 进度条
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: region.progress,
                      backgroundColor: AppTheme.primaryDark,
                      valueColor: AlwaysStoppedAnimation<Color>(region.color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${region.currentLevel}/${region.totalLevels}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: region.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (region.currentLevel < region.totalLevels)
              GestureDetector(
                onTap: () => _upgradeRegion(region.id),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: region.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '升级 (模拟)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: region.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '已完全激活',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

/// 脑区数据
class BrainRegion {
  final String id;
  final String name;
  final String function;
  final String description;
  final String icon;
  final Color color;
  final Offset position;
  final int totalLevels;
  int currentLevel;
  
  BrainRegion({
    required this.id,
    required this.name,
    required this.function,
    required this.description,
    required this.icon,
    required this.color,
    required this.position,
    required this.totalLevels,
    this.currentLevel = 0,
  });
  
  double get progress => currentLevel / totalLevels;
  bool get isMaxLevel => currentLevel >= totalLevels;
}

/// 神经连接绘制
class NeuralConnectionPainter extends CustomPainter {
  final List<BrainRegion> regions;
  final double progress;
  
  NeuralConnectionPainter({
    required this.regions,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // 绘制脑区之间的连接线
    for (int i = 0; i < regions.length; i++) {
      for (int j = i + 1; j < regions.length; j++) {
        final r1 = regions[i];
        final r2 = regions[j];
        
        final p1 = Offset(
          centerX + r1.position.dx * 120,
          centerY + r1.position.dy * 120,
        );
        final p2 = Offset(
          centerX + r2.position.dx * 120,
          centerY + r2.position.dy * 120,
        );
        
        // 根据两个脑区的激活程度决定线的亮度
        final avgProgress = (r1.progress + r2.progress) / 2;
        final opacity = 0.1 + (avgProgress * 0.4);
        
        final paint = Paint()
          ..color = AppTheme.accentCoral.withOpacity(opacity)
          ..strokeWidth = 1 + (avgProgress * 2)
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(p1, p2, paint);
        
        // 绘制流动的粒子效果
        if (avgProgress > 0.3) {
          final particlePaint = Paint()
            ..color = AppTheme.accentCoral.withOpacity(avgProgress)
            ..style = PaintingStyle.fill;
          
          final particleOffset = Offset.lerp(p1, p2, math.Random().nextDouble())!;
          canvas.drawCircle(particleOffset, 2, particlePaint);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
