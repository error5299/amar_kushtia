import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_typography.dart';
import '../auth/google_login_screen.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.05, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.15, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // Fast, responsive splash: 1000ms minimum branding exposure
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    User? resolvedUser;
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 1000)),
        _resolveAuthUser().then((user) => resolvedUser = user),
      ]);
    } catch (e) {
      debugPrint('[SplashScreen] Auth check note: $e');
      resolvedUser = _getCurrentUserFallback();
    }

    if (mounted) _proceedToNextScreen(resolvedUser);
  }

  Future<User?> _resolveAuthUser() async {
    try {
      final current = FirebaseAuth.instance.currentUser;
      if (current != null) return current;

      return await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(
            const Duration(milliseconds: 1500),
            onTimeout: () => FirebaseAuth.instance.currentUser,
          );
    } catch (e) {
      debugPrint('[SplashScreen] Auth stream error: $e');
      return _getCurrentUserFallback();
    }
  }

  User? _getCurrentUserFallback() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _proceedToNextScreen(User? authUser) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          if (authUser != null) {
            return const MainNavigationScreen();
          }
          return const GoogleLoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF042B1A), // Deep Forest Green
              Color(0xFF0B5233), // Amar Kushtia Brand Emerald
              Color(0xFF063B24), // Dark Olive Emerald
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Subtle ambient background glow circle
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withAlpha(25),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -50,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0B5233).withAlpha(30),
                      ),
                    ),
                  ),

                  // Center Logo & Title
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Logo with glowing border
                            Container(
                              width: 104,
                              height: 104,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(50),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withAlpha(40),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/icons/NEW-APP.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/icons/amar_kushtia.png',
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // App Name
                            const Text(
                              'আমার কুষ্টিয়া',
                              style: TextStyle(
                                fontFamily: AppTypography.primaryFont,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Tagline / Subtitle
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: const Text(
                                'ঐতিহ্য ও আধুনিকতার ডিজিটাল সেতুবন্ধন',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.primaryFont,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xD2FFFFFF),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom subtle loader & district tag
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'কুষ্টিয়া জেলা নাগরিক ডিজিটাল সেবা প্ল্যাটফর্ম',
                            style: TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xA0FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
