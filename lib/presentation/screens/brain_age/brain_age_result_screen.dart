import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 脑力年龄结果页面
class BrainAgeResultScreen extends StatelessWidget {
  const BrainAgeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📊', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                '测试结果',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                '开发中...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
