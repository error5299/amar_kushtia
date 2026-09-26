import 'package:flutter/material.dart';
import '../../features/profile/belayet_profile_screen.dart';
import '../../theme/app_typography.dart';

/// Simple credit footer — "Crafted with ❤️ by Belayet".
/// Tapping "Belayet" opens [BelayetProfileScreen].
/// Back-to-top FAB lives at the Scaffold level, not here.
class AppPageFooter extends StatelessWidget {
  const AppPageFooter({super.key});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const BelayetProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF5EE),
        border: Border(
          top: BorderSide(color: Color(0xFFD4E6DA), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Crafted with ❤️ by ',
            style: TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF536159),
            ),
          ),
          GestureDetector(
            onTap: () => _openProfile(context),
            child: const Text(
              'Belayet',
              style: TextStyle(
                fontFamily: AppTypography.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B5233),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF46AF6A),
                decorationThickness: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
