import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/action_buttons.dart';
import '../common/verification_badge.dart';

/// TPL-06: Map Marker Card
/// Compact bottom modal sheet preview when tapping any map marker.
class Tpl06MapMarkerCard extends StatelessWidget {
  final MasterRecord record;
  final VoidCallback onDetailsTap;

  const Tpl06MapMarkerCard({
    super.key,
    required this.record,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.getName(isBn),
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (record.subcategoryId != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.subcategoryId!,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                VerificationBadge(status: record.verificationStatus, compact: true),
              ],
            ),

            if (record.getAddress(isBn).isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      record.getAddress(isBn),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            Row(
              children: [
                if (record.hasCoordinates) ...[
                  Expanded(
                    child: DirectionButton(
                      latitude: record.latitude,
                      longitude: record.longitude,
                      label: record.getName(isBn),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (record.phonePrimary != null && record.phonePrimary!.isNotEmpty) ...[
                  CallButton(phoneNumber: record.phonePrimary, compact: true),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: onDetailsTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(80, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    l10n.viewDetails,
                    style: AppTypography.labelMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
