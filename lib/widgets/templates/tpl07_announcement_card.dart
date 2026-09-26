import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Model for Announcements / Notices
class Announcement {
  final String id;
  final String titleBn;
  final String titleEn;
  final String bodyBn;
  final String bodyEn;
  final DateTime publishFrom;
  final DateTime publishTo;
  final bool isUrgent;

  Announcement({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.bodyBn,
    required this.bodyEn,
    required this.publishFrom,
    required this.publishTo,
    this.isUrgent = false,
  });

  bool get isExpired => DateTime.now().isAfter(publishTo);

  String getTitle(bool isBn) => isBn ? titleBn : titleEn;
  String getBody(bool isBn) => isBn ? bodyBn : bodyEn;
}

/// TPL-07: Announcement Card
/// Displays public service announcements, emergency updates, or schedule changes.
class Tpl07AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const Tpl07AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (announcement.isExpired) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    final bgColor = announcement.isUrgent ? AppColors.emergencyContainer : AppColors.primaryContainer;
    final fgColor = announcement.isUrgent ? AppColors.emergencyDark : AppColors.primaryDark;
    final iconColor = announcement.isUrgent ? AppColors.emergency : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign_rounded, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.getTitle(isBn),
                        style: AppTypography.titleMedium.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (announcement.isUrgent) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emergency,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isBn ? 'জরুরি' : 'Urgent',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.getBody(isBn),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
