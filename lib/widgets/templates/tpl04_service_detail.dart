import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/healthcare_tables.dart';
import '../../models/master_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/action_buttons.dart';
import '../common/embedded_map_preview.dart';
import '../common/glass_card.dart';
import '../common/photo_carousel.dart';
import '../common/verification_badge.dart';

/// TPL-04: Service Detail
/// Redesigned with Glassmorphism, Photo Carousel (1+ photos), and Themed Embedded Map Preview.
/// Used for Healthcare facilities, Hospitals, and Government Administrative Offices.
class Tpl04ServiceDetail extends StatefulWidget {
  final MasterRecord record;
  final List<BedFeeRecord>? bedFees;
  final List<SurgeryRecord>? surgerySchedules;
  final List<AmbulanceModel>? ambulanceModels;

  const Tpl04ServiceDetail({
    super.key,
    required this.record,
    this.bedFees,
    this.surgerySchedules,
    this.ambulanceModels,
  });

  @override
  State<Tpl04ServiceDetail> createState() => _Tpl04ServiceDetailState();
}

class _Tpl04ServiceDetailState extends State<Tpl04ServiceDetail> {
  final TextEditingController _distanceController = TextEditingController(text: '15');
  double _calculatedAmbulanceFare = 300; // default 15km * 10 * 2 (round trip)

  void _calculateFare(String val) {
    final km = double.tryParse(val) ?? 0;
    setState(() {
      _calculatedAmbulanceFare = km * 10 * 2;
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final r = widget.record;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Photo Carousel (1+ Photos, Glassmorphism, Lightbox)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: PhotoCarousel(
              record: r,
              height: 220,
              overlayTopRight: VerificationBadge(status: r.verificationStatus),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Glassmorphic Header Card
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
                                  r.getName(isBn),
                                  style: AppTypography.displaySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                if (r.subcategoryId != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                                    ),
                                    child: Text(
                                      r.subcategoryId!,
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

                      if (r.getAddress(isBn).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.getAddress(isBn),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 14),

                      // Quick Action Buttons
                      Row(
                        children: [
                          if (r.phonePrimary != null && r.phonePrimary!.isNotEmpty) ...[
                            Expanded(
                              child: CallButton(
                                phoneNumber: r.phonePrimary,
                                isPrimary: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (r.hasCoordinates || (r.directionsUrl != null && r.directionsUrl!.isNotEmpty)) ...[
                            Expanded(
                              child: DirectionButton(
                                latitude: r.latitude,
                                longitude: r.longitude,
                                directionsUrl: r.directionsUrl,
                                label: r.getName(isBn),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (r.website != null && r.website!.isNotEmpty) ...[
                            WebsiteButton(url: r.website),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Embedded Themed Map Preview
                if (r.hasCoordinates || (r.mapEmbedUrl != null && r.mapEmbedUrl!.isNotEmpty)) ...[
                  Text(
                    isBn ? 'মানচিত্রে অবস্থান' : 'Location on Map',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  EmbeddedMapPreview(
                    latitude: r.latitude ?? 23.9012,
                    longitude: r.longitude ?? 89.1234,
                    directionsUrl: r.directionsUrl,
                    mapEmbedUrl: r.mapEmbedUrl,
                    title: r.getName(isBn),
                    address: r.getAddress(isBn),
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Services & Overview (Glassmorphic)
                if (r.getDescription(isBn).isNotEmpty || r.getShortDescription(isBn).isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              isBn ? 'বিবরণ ও সেবা' : 'Services & Overview',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r.getDescription(isBn).isNotEmpty ? r.getDescription(isBn) : r.getShortDescription(isBn),
                          style: AppTypography.bodyMedium.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Healthcare Bed Tariff Table (if healthcare)
                if (r.categoryId == 'healthcare' && widget.bedFees != null && widget.bedFees!.isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bed_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              isBn ? 'হাসপাতাল বেড ও কেবিন ফি তালিকা' : 'Hospital Bed & Cabin Tariff',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.bedFees!.length,
                          separatorBuilder: (context, _) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final bed = widget.bedFees![index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bed.bedType, style: AppTypography.titleSmall),
                                    Text(
                                      '${isBn ? "ধারণক্ষমতা:" : "Capacity:"} ${bed.capacityUnit}',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                Text(
                                  bed.dailyRentBdt == 0
                                      ? (isBn ? 'বিনামূল্যে' : 'Free')
                                      : '৳${bed.dailyRentBdt.toInt()}${isBn ? "/দিন" : "/day"}',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. Surgery Operation Schedule Table
                if (r.categoryId == 'healthcare' && widget.surgerySchedules != null && widget.surgerySchedules!.isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              isBn ? 'অপারেশন সময়সূচি ও সার্জন' : 'Surgery & Operation Schedule',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.surgerySchedules!.length,
                          separatorBuilder: (context, _) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final s = widget.surgerySchedules![index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.department, style: AppTypography.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  '${isBn ? "দিন:" : "Days:"} ${s.surgeryDays}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${isBn ? "মাইনর ফি:" : "Minor Fee:"} ${s.minorFee}',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                                    ),
                                    Text(
                                      '${isBn ? "মেজর ফি:" : "Major Fee:"} ${s.majorFee}',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 7. Interactive Ambulance Fare Calculator
                if (r.categoryId == 'healthcare') ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emergency_rounded, size: 18, color: AppColors.emergency),
                            const SizedBox(width: 8),
                            Text(
                              isBn ? 'অ্যাম্বুলেন্স ভাড়া ক্যালকুলেটর' : 'Ambulance Fare Estimator',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn
                              ? 'সরকারি বিধি অনুযায়ী: ১০ টাকা/কিমি (আসা-যাওয়া দ্বিমুখী গণনা)'
                              : 'Official Tariff: 10 BDT/km (Round-trip basis)',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _distanceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: isBn ? 'দূরত্ব (কিমি)' : 'Distance (km)',
                                  suffixText: 'km',
                                  isDense: true,
                                ),
                                onChanged: _calculateFare,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isBn ? 'আনুমানিক ভাড়া' : 'Estimated Fare', style: AppTypography.labelSmall),
                                  Text(
                                    '৳${_calculatedAmbulanceFare.toInt()}',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${isBn ? "জরুরি কল:" : "Hotline:"} 071-62449',
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const CallButton(phoneNumber: '071-62449', isPrimary: true, compact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 8. Source and Verification Metadata
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
}
