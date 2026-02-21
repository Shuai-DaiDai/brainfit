import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/mock_firebase_service.dart';
import 'core/services/local_storage_service.dart';

/// 无Firebase版本 - 本地测试入口
/// 所有数据存储在本地，无需网络连接
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置首选方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // 初始化 Mock Firebase（本地模式）
  await MockFirebaseService.initialize();
  
  // 初始化本地存储
  await LocalStorageService.initialize();
  
  runApp(
    const ProviderScope(
      child: BrainFitApp(),
    ),
  );
}
