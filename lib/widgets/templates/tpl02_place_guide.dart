import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/action_buttons.dart';
import '../common/embedded_map_preview.dart';
import '../common/glass_card.dart';
import '../common/photo_carousel.dart';
import '../common/verification_badge.dart';

/// TPL-02: Place Guide
/// Redesigned with Glassmorphism, Photo Carousel (1+ photos), and Themed Embedded Map Preview.
/// Detail template for Tourism, Cultural Heritage, and Historical Sites.
class Tpl02PlaceGuide extends StatelessWidget {
  final MasterRecord record;

  const Tpl02PlaceGuide({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Photo Carousel (1+ Photos, Glassmorphism, Lightbox)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: PhotoCarousel(
              record: record,
              height: 250,
              overlayTopRight: VerificationBadge(status: record.verificationStatus),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Glassmorphic Title & Category Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.getName(isBn),
                                  style: AppTypography.displaySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                if (record.subcategoryId != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                                    ),
                                    child: Text(
                                      record.subcategoryId!,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Location Address
                      if (record.getAddress(isBn).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record.getAddress(isBn),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Quick Action Bar
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (record.hasCoordinates || (record.directionsUrl != null && record.directionsUrl!.isNotEmpty)) ...[
                            Expanded(
                              child: DirectionButton(
                                latitude: record.latitude,
                                longitude: record.longitude,
                                directionsUrl: record.directionsUrl,
                                label: record.getName(isBn),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (record.phonePrimary != null && record.phonePrimary!.isNotEmpty) ...[
                            Expanded(
                              child: CallButton(
                                phoneNumber: record.phonePrimary,
                                isPrimary: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (record.website != null && record.website!.isNotEmpty) ...[
                            WebsiteButton(url: record.website),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Embedded Themed Map Preview
                if (record.hasCoordinates || (record.mapEmbedUrl != null && record.mapEmbedUrl!.isNotEmpty)) ...[
                  Text(
                    isBn ? 'মানচিত্রে অবস্থান' : 'Location on Map',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  EmbeddedMapPreview(
                    latitude: record.latitude ?? 23.9012,
                    longitude: record.longitude ?? 89.1234,
                    directionsUrl: record.directionsUrl,
                    mapEmbedUrl: record.mapEmbedUrl,
                    title: record.getName(isBn),
                    address: record.getAddress(isBn),
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Entry Fee & Timings (Glassmorphic Card)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            isBn ? 'সময়সূচি ও প্রবেশ ফি' : 'Timing & Admission Fee',
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoBlock(
                              icon: Icons.schedule_rounded,
                              label: isBn ? 'খোলা থাকে' : 'Opening Hours',
                              value: record.openingHours ?? (isBn ? 'সকাল ৯টা – বিকেল ৫টা' : '09:00 AM – 05:00 PM'),
                            ),
                          ),
                          Expanded(
                            child: _infoBlock(
                              icon: Icons.event_busy_rounded,
                              label: isBn ? 'ছুটির দিন' : 'Weekly Off',
                              value: record.offDays ?? (isBn ? 'রবিবার (সরকারি ছুটি)' : 'Sunday'),
                            ),
                          ),
                        ],
                      ),
                      if (record.feeType != null || record.feeAmount != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isBn ? 'প্রবেশ মূল্য:' : 'Entry Tariff:', style: AppTypography.labelMedium),
                            Text(
                              record.feeAmount != null
                                  ? '৳${record.feeAmount!.toInt()}'
                                  : (record.feeType ?? (isBn ? 'বিনামূল্যে' : 'Free')),
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. History & Overview
                if (record.getDescription(isBn).isNotEmpty || record.getShortDescription(isBn).isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_edu_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              isBn ? 'ইতিহাস ও পরিচয়' : 'History & Heritage',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          record.getDescription(isBn).isNotEmpty
                              ? record.getDescription(isBn)
                              : record.getShortDescription(isBn),
                          style: AppTypography.bodyMedium.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. Source and Verification Metadata
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'উৎস: Master Data Document v2.0 | যাচাইকৃত তথ্য'
                              : 'Source: Master Data Document v2.0 | Verified Civic Records',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
