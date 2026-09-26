import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/google_logo.dart';
import '../main_navigation_screen.dart';


class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await AuthService.instance.signInWithGoogle();
      if (credential == null) {
        // User cancelled Google account picker
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Successful sign in! Navigate immediately with a smooth fade/scale transition to Home
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'স্বাগতম, ${credential.user?.displayName ?? "নাগরিক"}! সফলভাবে লগইন হয়েছে।',
                    style: GoogleFonts.googleSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0B5233),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 650),
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[GoogleLoginScreen] Sign-In Error: $e');
      if (mounted) {
        setState(() {
          final errStr = e.toString();
          if (errStr.contains('network') || errStr.contains('SocketException')) {
            _errorMessage = 'ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না। নেটওয়ার্ক পরীক্ষা করে আবার চেষ্টা করুন।';
          } else if (errStr.contains('ApiException: 10') || errStr.contains('10:')) {
            _errorMessage = 'গুগল সাইন-ইন কনফিগারেশন ত্রুটি (Code 10: SHA-1 Fingerprint মিসিং)।';
          } else if (errStr.contains('ApiException: 12500')) {
            _errorMessage = 'গুগল প্লে সার্ভিস ত্রুটি (Code 12500)। প্লে সার্ভিস আপডেট আছে কিনা দেখুন।';
          } else {
            _errorMessage = 'লগইন সম্পন্ন করা যায়নি ($e)';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Brand Logo Badge
                  Center(
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B5233).withAlpha(25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/icons/amar_kushtia.png',
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title & Tagline
                  Text(
                    'আমার কুষ্টিয়া',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0B5233),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'কুষ্টিয়া জেলা নাগরিক ডিজিটাল সেবা ও সমন্বিত প্ল্যাটফর্ম',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF55605A),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feature Cards Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: Icons.emergency_rounded,
                          iconBg: const Color(0xFFFEE2E2),
                          iconColor: const Color(0xFFDC2626),
                          title: 'জরুরি সেবা ও জাতীয় হটলাইন',
                          subtitle: 'পুলিশ, ফায়ার সার্ভিস ও অ্যাম্বুলেন্স এক ক্লিকে',
                        ),
                        const Divider(height: 22, thickness: 0.7, color: Color(0xFFF0F2F1)),
                        _buildFeatureRow(
                          icon: Icons.local_hospital_rounded,
                          iconBg: const Color(0xFFEAF5EE),
                          iconColor: const Color(0xFF0B5233),
                          title: 'হাসপাতাল, বেড ও স্বাস্থ্যসেবা',
                          subtitle: '২৫০ শয্যা জেনারেল হাসপাতাল ও উপজেলা ক্লিনিক',
                        ),
                        const Divider(height: 22, thickness: 0.7, color: Color(0xFFF0F2F1)),
                        _buildFeatureRow(
                          icon: Icons.attractions_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'দর্শনীয় স্থান ও পর্যটন তথ্য',
                          subtitle: 'শিলাইদহ কুঠিবাড়ি, লালন শাহ মাজার ও সেতু',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Error Message (if any)
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.googleSans(
                                fontSize: 13,
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Prominent Google Sign-In Button
                  InkWell(
                    onTap: _isLoading ? null : _handleGoogleSignIn,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF0B5233),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Official 4-color Google "G" logo
                                const GoogleLogo(size: 24),
                                const SizedBox(width: 14),
                                Text(
                                  'Google দিয়ে লগইন করুন',
                                  style: GoogleFonts.googleSans(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Optional Guest Skip Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF0B5233)),
                      label: Text(
                        'লগইন না করে পরবর্তীতে দেখুন',
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B5233),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Privacy / Terms Note
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text(
                          'নিরাপদ ও এনক্রিপ্টেড গুগল অথেনটিকেশন',
                          style: GoogleFonts.googleSans(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.googleSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.googleSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
