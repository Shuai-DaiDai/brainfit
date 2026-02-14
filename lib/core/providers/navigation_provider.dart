import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/brain_age/brain_age_test_screen.dart';
import '../../presentation/screens/brain_age/brain_age_result_screen.dart';
import '../../presentation/screens/breathing/breathing_screen.dart';
import '../../presentation/screens/breathing/resonant_breathing_screen.dart';
import '../../presentation/screens/breathing/cyclic_sighing_screen.dart';
import '../../presentation/screens/breathing/four_seven_eight_screen.dart';
import '../../presentation/screens/breathing/box_breathing_screen.dart';
import '../../presentation/screens/meditation/meditation_screen.dart';
import '../../presentation/screens/dual_nback/dual_nback_screen.dart';
import '../../presentation/screens/streak/streak_screen.dart';
import '../../presentation/screens/rewards/rewards_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/neural_network/neural_network_screen.dart';
import '../../presentation/screens/weekly_report/weekly_report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/brain-age-test',
        builder: (context, state) => const BrainAgeTestScreen(),
      ),
      GoRoute(
        path: '/brain-age-result',
        builder: (context, state) => const BrainAgeResultScreen(),
      ),
      GoRoute(
        path: '/breathing',
        builder: (context, state) => const BreathingScreen(),
      ),
      GoRoute(
        path: '/breathing/resonant',
        builder: (context, state) => const ResonantBreathingScreen(),
      ),
      GoRoute(
        path: '/breathing/cyclic-sighing',
        builder: (context, state) => const CyclicSighingScreen(),
      ),
      GoRoute(
        path: '/breathing/four-seven-eight',
        builder: (context, state) => const FourSevenEightScreen(),
      ),
      GoRoute(
        path: '/breathing/box',
        builder: (context, state) => const BoxBreathingScreen(),
      ),
      GoRoute(
        path: '/meditation',
        builder: (context, state) => const MeditationScreen(),
      ),
      GoRoute(
        path: '/dual-nback',
        builder: (context, state) => const DualNBackScreen(),
      ),
      GoRoute(
        path: '/streak',
        builder: (context, state) => const StreakScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/neural-network',
        builder: (context, state) => const NeuralNetworkScreen(),
      ),
      GoRoute(
        path: '/weekly-report',
        builder: (context, state) => const WeeklyReportScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
