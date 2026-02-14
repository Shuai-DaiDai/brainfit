import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Firebase 服务管理类
/// 封装所有 Firebase 相关操作
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase 实例
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  // 当前用户
  static User? get currentUser => auth.currentUser;
  static String? get userId => currentUser?.uid;
  static bool get isAuthenticated => currentUser != null;

  /// 初始化 Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // 设置 Firestore 离线持久化
    await firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
    
    if (kDebugMode) {
      print('✅ Firebase 初始化完成');
    }
  }

  /// 匿名登录（快速体验）
  static Future<User?> signInAnonymously() async {
    try {
      final credential = await auth.signInAnonymously();
      await _createUserDocument(credential.user!);
      return credential.user;
    } catch (e) {
      print('匿名登录失败: $e');
      return null;
    }
  }

  /// 邮箱密码注册
  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createUserDocument(credential.user!);
      return credential.user;
    } catch (e) {
      print('注册失败: $e');
      return null;
    }
  }

  /// 邮箱密码登录
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('登录失败: $e');
      return null;
    }
  }

  /// 手机号登录 - 发送验证码
  static Future<void> sendPhoneCode(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
    Function(String error) onError,
  ) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 自动验证完成（仅限 Android）
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? '验证失败');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// 手机号登录 - 验证验证码
  static Future<User?> verifyPhoneCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await auth.signInWithCredential(credential);
      if (result.user != null) {
        await _createUserDocument(result.user!);
      }
      return result.user;
    } catch (e) {
      print('验证码验证失败: $e');
      return null;
    }
  }

  /// 退出登录
  static Future<void> signOut() async {
    await auth.signOut();
  }

  /// 创建用户文档
  static Future<void> _createUserDocument(User user) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    
    if (!snapshot.exists) {
      await userRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '脑力运动员',
        'brainAge': 28,
        'chronologicalAge': 28,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // 初始化 streak 数据
      await userRef.collection('stats').doc('streak').set({
        'currentStreak': 0,
        'longestStreak': 0,
        'totalCheckIns': 0,
        'lastCheckIn': null,
      });
      
      // 初始化奖励数据
      await userRef.collection('stats').doc('rewards').set({
        'balance': 0,
        'totalEarned': 0,
        'totalSpent': 0,
      });
    }
  }

  /// 获取用户数据
  static Future<Map<String, dynamic>?> getUserData() async {
    if (userId == null) return null;
    
    final doc = await firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  /// 更新用户数据
  static Future<void> updateUserData(Map<String, dynamic> data) async {
    if (userId == null) return;
    
    await firestore.collection('users').doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 保存练习记录
  static Future<void> savePracticeSession({
    required String type,
    required int duration,
    int? score,
    Map<String, dynamic>? metadata,
  }) async {
    if (userId == null) return;
    
    await firestore
        .collection('users')
        .doc(userId)
        .collection('practiceSessions')
        .add({
      'type': type,
      'duration': duration,
      'score': score,
      'metadata': metadata ?? {},
      'completedAt': FieldValue.serverTimestamp(),
    });
    
    // 记录分析事件
    await analytics.logEvent(
      name: 'practice_completed',
      parameters: {
        'type': type,
        'duration': duration,
        'score': score ?? 0,
      },
    );
  }

  /// 获取练习历史
  static Stream<QuerySnapshot> getPracticeHistory({int limit = 50}) {
    if (userId == null) return const Stream.empty();
    
    return firestore
        .collection('users')
        .doc(userId)
        .collection('practiceSessions')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// 更新 Streak
  static Future<void> updateStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastCheckIn,
  }) async {
    if (userId == null) return;
    
    await firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('streak')
        .update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckIn': Timestamp.fromDate(lastCheckIn),
    });
  }

  /// 更新奖励余额
  static Future<void> updateBalance({
    required int balance,
    required int totalEarned,
  }) async {
    if (userId == null) return;
    
    await firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('rewards')
        .update({
      'balance': balance,
      'totalEarned': totalEarned,
    });
  }

  /// 解锁成就
  static Future<void> unlockAchievement(String achievementId) async {
    if (userId == null) return;
    
    await firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({
      'unlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // 记录分析事件
    await analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {'achievement_id': achievementId},
    );
  }

  /// 获取用户成就
  static Stream<DocumentSnapshot> getAchievement(String achievementId) {
    if (userId == null) return const Stream.empty();
    
    return firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .snapshots();
  }

  /// 同步本地数据到云端
  static Future<void> syncLocalDataToCloud({
    required int brainAge,
    required int balance,
    required int currentStreak,
    required int longestStreak,
    required int totalPractices,
  }) async {
    if (userId == null) return;
    
    final batch = firestore.batch();
    final userRef = firestore.collection('users').doc(userId);
    
    // 更新用户主数据
    batch.update(userRef, {
      'brainAge': brainAge,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // 更新统计数据
    batch.update(userRef.collection('stats').doc('rewards'), {
      'balance': balance,
    });
    
    batch.update(userRef.collection('stats').doc('streak'), {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    });
    
    await batch.commit();
  }
}
