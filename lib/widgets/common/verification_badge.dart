import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class VerificationBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const VerificationBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = status.toLowerCase();

    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (s.startsWith('verified')) {
      bg = AppColors.verifiedBg;
      fg = AppColors.verified;
      icon = Icons.verified_rounded;
      label = l10n.verified;
    } else if (s.contains('partially') || s.contains('partial')) {
      bg = AppColors.partiallyVerifiedBg;
      fg = AppColors.partiallyVerified;
      icon = Icons.published_with_changes_rounded;
      label = l10n.partiallyVerified;
    } else {
      bg = AppColors.needsVerificationBg;
      fg = AppColors.needsVerification;
      icon = Icons.help_outline_rounded;
      label = l10n.needsVerification;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: fg),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withAlpha(50), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
