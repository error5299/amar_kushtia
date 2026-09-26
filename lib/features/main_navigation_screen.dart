import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import '../theme/app_typography.dart';
import 'home/home_screen.dart';
import 'emergency/emergency_screen.dart';
import 'search/global_search_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  // Performance optimization: Lazy-load tabs so only HomeScreen builds on startup
  final Set<int> _initializedIndices = {0};

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _initializedIndices.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    final screens = [
      const HomeScreen(),
      _initializedIndices.contains(1) ? const EmergencyScreen() : const SizedBox.shrink(),
      _initializedIndices.contains(2) ? const GlobalSearchScreen() : const SizedBox.shrink(),
      _initializedIndices.contains(3) ? const SettingsScreen() : const SizedBox.shrink(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
          ),
        ),
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: isBn ? 'হোম' : 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.emergency_outlined,
                activeIcon: Icons.emergency_rounded,
                label: isBn ? 'জরুরি' : 'Emergency',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: isBn ? 'সার্চ' : 'Search',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: isBn ? 'সেটিংস' : 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD4EADB) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? const Color(0xFF0B5233) : const Color(0xFF555E58),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0B5233) : const Color(0xFF555E58),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
