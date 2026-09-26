import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  final bool initialIsSignUp;
  const LoginScreen({super.key, this.initialIsSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isSignUp;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseService.instance.auth;

      if (_isSignUp) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (_nameController.text.trim().isNotEmpty) {
          await credential.user?.updateDisplayName(_nameController.text.trim());
        }
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSignUp
                  ? 'অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে!'
                  : 'সফলভাবে লগইন হয়েছে!',
              style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0B5233),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getLocalizedError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ত্রুটি ঘটেছে: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLocalizedError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'পাসওয়ার্ড অথবা ইমেইল সঠিক নয়।';
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট নিবন্ধিত আছে।';
      case 'invalid-email':
        return 'অনুগ্রহ করে সঠিক ইমেইল ঠিকানা প্রদান করুন।';
      case 'weak-password':
        return 'পাসওয়ার্ডটি দুর্বল (কমপক্ষে ৬ অক্ষর হওয়া প্রয়োজন)।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ পরীক্ষা করুন।';
      default:
        return 'লগইন ব্যর্থ হয়েছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন।';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Icon & Titles
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B5233).withAlpha(25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icons/amar_kushtia.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSignUp ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'Amar Kushtia-তে স্বাগতম',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B5233),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'আপনার অ্যাকাউন্ট খুলে নাগরিক সেবার সাথে যুক্ত থাকুন'
                        : 'নাগরিক সেবা ও প্রয়োজনীয় তথ্যের সাথে যুক্ত থাকুন',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segmented Switcher (লগইন / সাইন আপ)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EBE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isSignUp ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !_isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'লগইন',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                  color: !_isSignUp ? const Color(0xFF0B5233) : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isSignUp ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'রেজিস্টার',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                  color: _isSignUp ? const Color(0xFF0B5233) : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                                  const SizedBox(width: 8),
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

                          if (_isSignUp) ...[
                            Text(
                              'আপনার নাম',
                              style: GoogleFonts.googleSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.googleSans(fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'পূর্ণ নাম লিখুন (যেমন: বেলায়েত হোসেন)',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: (val) {
                                if (_isSignUp && (val == null || val.trim().isEmpty)) {
                                  return 'নাম প্রদান করুন';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          Text(
                            'ইমেইল ঠিকানা',
                            style: GoogleFonts.googleSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.googleSans(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: 'example@gmail.com',
                              icon: Icons.mail_outline_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'ইমেইল ঠিকানা প্রদান করুন';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'সঠিক ইমেইল ফরম্যাট লিখুন';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'পাসওয়ার্ড',
                            style: GoogleFonts.googleSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.googleSans(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: 'কমপক্ষে ৬ অক্ষর',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                              }
                              return null;
                            },
                          ),

                          if (_isSignUp) ...[
                            const SizedBox(height: 14),
                            Text(
                              'পাসওয়ার্ড নিশ্চিত করুন',
                              style: GoogleFonts.googleSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.googleSans(fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'পুনরায় পাসওয়ার্ড লিখুন',
                                icon: Icons.lock_clock_outlined,
                              ),
                              validator: (val) {
                                if (_isSignUp && val != _passwordController.text) {
                                  return 'পাসওয়ার্ড দুটি মেলেনি';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 22),

                          // Submit Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B5233),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'অ্যাকাউন্ট তৈরি করুন' : 'লগইন করুন',
                                    style: GoogleFonts.googleSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Guest option
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF6B7280)),
                      label: Text(
                        'এখনই নয়, গেস্ট হিসেবে দেখুন',
                        style: GoogleFonts.googleSans(
                          fontSize: 13.5,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.googleSans(color: const Color(0xFF9CA3AF), fontSize: 13.5),
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF4F6F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0B5233), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }
}
