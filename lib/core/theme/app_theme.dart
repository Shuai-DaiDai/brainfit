import 'package:flutter/material.dart';

/// BrainFit 应用主题配置
/// 使用深色主题，强调色为珊瑚红和深蓝色系
class AppTheme {
  // 核心颜色
  static const Color primaryDark = Color(0xFF1A1A2E);    // 深蓝黑 - 主背景
  static const Color secondaryDark = Color(0xFF16213E);  // 深蓝 - 卡片背景
  static const Color accentBlue = Color(0xFF0F3460);     // 蓝色 - 强调
  static const Color accentCoral = Color(0xFFE94560);    // 珊瑚红 - 主要强调色
  static const Color accentGold = Color(0xFFFFB800);     // 金色 - 奖励/成就
  static const Color accentGreen = Color(0xFF00D9C0);    // 青绿 - 成功/正面
  static const Color accentPurple = Color(0xFF9B5DE5);   // 紫色 - 放松/冥想
  static const Color accentAmber = Color(0xFFF4A261);    // 琥珀色 - 专注/箱式呼吸
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color textMuted = Color(0xFF6B6B80);
  
  // 功能颜色
  static const Color streakFlame = Color(0xFFFF6B35);
  static const Color brainGradientStart = Color(0xFF667EEA);
  static const Color brainGradientEnd = Color(0xFF764BA2);
  static const Color breathingInhale = Color(0xFF4ECDC4);
  static const Color breathingHold = Color(0xFFFFE66D);
  static const Color breathingExhale = Color(0xFF6C5CE7);
  
  // 渐变定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brainGradientStart, brainGradientEnd],
  );
  
  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCoral, Color(0xFFFF6B6B)],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, secondaryDark],
  );
  
  // 阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: accentCoral.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accentCoral.withOpacity(0.3),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];

  // 主题数据
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentCoral,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentCoral,
        secondary: accentBlue,
        surface: secondaryDark,
        background: primaryDark,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      
      // 文字主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMuted,
          height: 1.4,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: secondaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCoral,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentCoral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // 底部导航栏
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryDark,
        selectedItemColor: accentCoral,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // 进度指示器
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentCoral,
        linearTrackColor: secondaryDark,
      ),
    );
  }
}
