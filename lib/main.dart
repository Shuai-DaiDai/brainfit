import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/local_storage_service.dart';

/// BrainFit 主入口 - 纯本地版
/// 无需 Firebase，所有数据存储在本地
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
  
  // 初始化本地存储
  await LocalStorageService().initialize();
  
  runApp(
    const ProviderScope(
      child: BrainFitApp(),
    ),
  );
}
