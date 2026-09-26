import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/action_buttons.dart';
import '../common/verification_badge.dart';
import '../../features/admin/admin_master_records_screen.dart';

/// TPL-01: Directory Card
/// Standard clean card for Emergency, Police, Fire, National Helplines, Government Offices.
class Tpl01DirectoryCard extends ConsumerWidget {
  final MasterRecord record;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const Tpl01DirectoryCard({
    super.key,
    required this.record,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    return Card(
      elevation: 0,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name & Verification Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.getName(isBn),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (_resolveUpazilaName(record.upazilaId, isBn).isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                            if (record.subcategoryId != null && record.subcategoryId!.isNotEmpty)
                              Text(
                                record.subcategoryId!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  VerificationBadge(status: record.verificationStatus, compact: true),
                  if (isAdmin) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => showEditMasterRecordDialog(context, record, isBn),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5EE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0B5233).withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFF0B5233)),
                            const SizedBox(width: 3),
                            Text(
                              isBn ? 'এডিট' : 'Edit',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B5233),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Short Description
              if (record.getShortDescription(isBn).isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  record.getShortDescription(isBn),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Address & Location
              if (record.getAddress(isBn).isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
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
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Action Row: Primary Phone + Call Button + Directions / Details
              Row(
                children: [
                  if (record.phonePrimary != null && record.phonePrimary!.isNotEmpty) ...[
                    Icon(
                      record.categoryId == 'emergency' ? Icons.emergency_rounded : Icons.phone_outlined,
                      size: 16,
                      color: record.categoryId == 'emergency' ? AppColors.emergency : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        record.phonePrimary!,
                        style: AppTypography.labelLarge.copyWith(
                          color: record.categoryId == 'emergency' ? AppColors.emergency : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CallButton(
                      phoneNumber: record.phonePrimary,
                      isPrimary: true,
                      compact: record.hasCoordinates || (record.website != null && record.website!.isNotEmpty),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],

                  if (record.hasCoordinates) ...[
                    const SizedBox(width: 8),
                    DirectionButton(
                      latitude: record.latitude,
                      longitude: record.longitude,
                      label: record.getName(isBn),
                      compact: true,
                    ),
                  ],

                  if (record.website != null && record.website!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    WebsiteButton(url: record.website),
                  ],
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

