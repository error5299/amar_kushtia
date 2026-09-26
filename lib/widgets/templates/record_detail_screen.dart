import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/auth_provider.dart';
import '../../features/admin/admin_master_records_screen.dart';
import 'tpl02_place_guide.dart';
import 'tpl04_service_detail.dart';

/// Universal Details Screen for any MasterRecord in Amar Kushtia.
/// Intelligently renders Tpl02PlaceGuide (Tourism/Culture/Heritage) or
/// Tpl04ServiceDetail (Healthcare/Police/Fire/Gov/Transport/Services)
/// with unified header, direct call action, and copy/share capability.
class RecordDetailScreen extends ConsumerWidget {
  final MasterRecord record;

  const RecordDetailScreen({
    super.key,
    required this.record,
  });

  /// Universal navigation helper to open details for any record
  static void open(BuildContext context, MasterRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordDetailScreen(record: record),
      ),
    );
  }

  void _shareRecord(BuildContext context, bool isBn) {
    final name = record.getName(isBn);
    final address = record.getAddress(isBn);
    final phone = record.phonePrimary ?? '';
    final text = '$name\n${address.isNotEmpty ? "$address\n" : ""}${phone.isNotEmpty ? "${isBn ? "যোগাযোগ:" : "Phone:"} $phone\n" : ""}\n[Amar Kushtia]';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBn ? 'তথ্য ক্লিপবোর্ডে কপি করা হয়েছে' : 'Information copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\s+'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    final bedFees = ref.watch(bedFeesProvider).valueOrNull ?? SeedMasterData.bedFees;
    final surgeries = ref.watch(surgerySchedulesProvider).valueOrNull ?? SeedMasterData.surgerySchedules;
    final ambulances = ref.watch(ambulanceModelsProvider);

    final isTourismOrCultural = record.categoryId == 'tourism' ||
        record.categoryId == 'food' ||
        record.categoryId == 'craft';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.getName(isBn),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (record.subcategoryId != null)
              Text(
                record.subcategoryId!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          // Admin Quick Edit Action
          if (isAdmin)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
              ),
              tooltip: isBn ? 'তথ্য এডিট করুন (Admin)' : 'Edit Record',
              onPressed: () => showEditMasterRecordDialog(context, record, isBn),
            ),

          // Quick Call Action in App Bar if phone exists
          if (record.phonePrimary != null && record.phonePrimary!.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: AppColors.primary, size: 18),
              ),
              tooltip: isBn ? 'সরাসরি কল করুন' : 'Call Now',
              onPressed: () => _callPhone(record.phonePrimary!),
            ),

          // Share / Copy Action
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: isBn ? 'তথ্য কপি করুন' : 'Copy Info',
            onPressed: () => _shareRecord(context, isBn),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isTourismOrCultural
          ? Tpl02PlaceGuide(record: record)
          : Tpl04ServiceDetail(
              record: record,
              bedFees: bedFees,
              surgerySchedules: surgeries,
              ambulanceModels: ambulances,
            ),
    );
  }
}
