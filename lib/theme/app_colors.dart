import 'package:flutter/material.dart';

/// AppColors defines the complete brand visual palette for "আমার কুষ্টিয়া".
/// Primary identity is Deep Natural Green, inspired by Kushtia's heritage,
/// the Gorai-Padma rivers, and the official district identity.
class AppColors {
  AppColors._();

  // Primary Brand Colors (sampled directly from official "আমার কুষ্টিয়া" logo assets)
  static const Color primary = Color(0xFF0B5233); // Logo Primary Deep Forest Green
  static const Color primaryDark = Color(0xFF063A23); // Logo Deep Shadow Green
  static const Color primaryLight = Color(0xFF46AF6A); // Logo Fresh Vibrant Leaf & Bridge Green
  static const Color primaryContainer = Color(0xFFEAF5EE); // Fresh subtle mint container

  // Secondary & Accents (directly from logo wave & pin)
  static const Color secondary = Color(0xFF46AF6A); // Logo Vibrant Green
  static const Color secondaryDark = Color(0xFF147F45); // Logo Mid River Wave Green
  static const Color secondaryLight = Color(0xFFEAF5EE);
  static const Color accent = Color(0xFF147F45); // Logo Wave Accent

  // Background & Surfaces
  static const Color background = Color(0xFFF7FAF8); // Clean subtle mint-tinted white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFF6F1);
  static const Color cardBorder = Color(0xFFE0ECE3);

  // Typography & Content
  static const Color textPrimary = Color(0xFF1A1F1C); // Dark Charcoal
  static const Color textSecondary = Color(0xFF536159);
  static const Color textMuted = Color(0xFF829188);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Emergency & Alerts (strictly reserved for safety/emergency)
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyContainer = Color(0xFFFFEBEE);
  static const Color emergencyDark = Color(0xFFB71C1C);

  // Verification Badges
  static const Color verified = Color(0xFF1B5E20);
  static const Color verifiedBg = Color(0xFFE8F5E9);
  static const Color partiallyVerified = Color(0xFFE65100);
  static const Color partiallyVerifiedBg = Color(0xFFFFF3E0);
  static const Color needsVerification = Color(0xFF616161);
  static const Color needsVerificationBg = Color(0xFFEEEEEE);

  // Category Colors
  static const Color catEmergency = Color(0xFFD32F2F);
  static const Color catHealthcare = Color(0xFF0288D1);
  static const Color catPolice = Color(0xFF1565C0);
  static const Color catFire = Color(0xFFE64A19);
  static const Color catTransport = Color(0xFF00796B);
  static const Color catTourism = Color(0xFF5D4037);
  static const Color catGov = Color(0xFF455A64);
  static const Color catEducation = Color(0xFF6A1B9A);
  static const Color catFood = Color(0xFFF57C00);
  static const Color catCraft = Color(0xFF00897B);

  // Status & System
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
}
