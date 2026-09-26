import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/verification_badge.dart';

/// TPL-05: Product / Vendor Card
/// Used for GI Products: Tiler Khaja of Kushtia and Kumarkhali Bed Sheet.
class Tpl05ProductCard extends StatelessWidget {
  final MasterRecord record;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const Tpl05ProductCard({
    super.key,
    required this.record,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return Card(
      elevation: 0,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge: GI Product tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.catFood.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, size: 14, color: AppColors.catFood),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'ভৌগোলিক নির্দেশক (জিআই)' : 'GI Recognized Product',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.catFood,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (record.upazilaId != null && record.upazilaId!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF5EE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBCE3C9), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 11,
                                  color: Color(0xFF0B5233),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _resolveUpazilaName(record.upazilaId, isBn),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: const Color(0xFF0B5233),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  VerificationBadge(status: record.verificationStatus, compact: true),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                record.getName(isBn),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                record.getShortDescription(isBn),
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),

              if (record.getDescription(isBn).isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  record.getDescription(isBn),
                  style: AppTypography.bodySmall.copyWith(height: 1.45),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            record.getAddress(isBn),
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'ঐতিহ্যবাহী পণ্য' : 'Heritage Item',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _resolveUpazilaName(String? upzId, bool isBn) {
    if (upzId == null || upzId.isEmpty) return '';
    final lower = upzId.toLowerCase();
    if (lower.contains('upz-001') || lower.contains('daulatpur')) {
      return isBn ? 'দৌলতপুর' : 'Daulatpur';
    } else if (lower.contains('upz-002') || lower.contains('sadar')) {
      return isBn ? 'কুষ্টিয়া সদর' : 'Kushtia Sadar';
    } else if (lower.contains('upz-003') || lower.contains('mirpur')) {
      return isBn ? 'মিরপুর' : 'Mirpur';
    } else if (lower.contains('upz-004') || lower.contains('kumarkhali')) {
      return isBn ? 'কুমারখালী' : 'Kumarkhali';
    } else if (lower.contains('upz-005') || lower.contains('bheramara')) {
      return isBn ? 'ভেড়ামারা' : 'Bheramara';
    } else if (lower.contains('upz-006') || lower.contains('khoksa') || lower.contains('khoksha')) {
      return isBn ? 'খোকসা' : 'Khoksa';
    }
    return '';
  }
}
