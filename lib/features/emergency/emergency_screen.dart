import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/national_hotline.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/action_buttons.dart';
import '../../widgets/common/verification_badge.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../widgets/templates/tpl01_directory_card.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final hotlines = ref.watch(nationalHotlinesProvider).valueOrNull ?? SeedMasterData.nationalHotlines;
    final recordsAsync = ref.watch(masterRecordsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catEmergency),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.emergency,
          labelColor: AppColors.emergency,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.labelLarge,
          tabs: [
            Tab(text: isBn ? 'দ্রুত কল' : 'Quick Call'),
            Tab(text: isBn ? 'জাতীয় হটলাইন' : 'National Hotlines'),
            Tab(text: isBn ? 'থানা ও ফায়ার' : 'Police & Fire'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Quick Call Primary Emergencies
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'জীবন রক্ষাকারী প্রধান হটলাইন' : 'Primary Life-Saving Hotlines',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // 999
                _primaryCallCard(
                  number: '999',
                  title: isBn ? 'জাতীয় জরুরি সেবা (৯৯৯)' : 'National Emergency Service (999)',
                  subtitle: isBn ? 'পুলিশ, ফায়ার সার্ভিস ও সরকারি অ্যাম্বুলেন্স সহায়তা (২৪/৭ ফ্রি)' : 'Police, Fire Service & Ambulance (24/7 Free)',
                  color: AppColors.emergency,
                ),
                const SizedBox(height: 12),

                // 102
                _primaryCallCard(
                  number: '102',
                  title: isBn ? 'ফায়ার সার্ভিস হটলাইন (১০২)' : 'Fire Service Central (102)',
                  subtitle: isBn ? 'অগ্নিকাণ্ড ও দুর্যোগ উদ্ধার তৎপরতা' : 'Fire rescue and emergency operations',
                  color: const Color(0xFFE64A19),
                ),
                const SizedBox(height: 12),

                // 333
                _primaryCallCard(
                  number: '333',
                  title: isBn ? 'সরকারি তথ্য ও পরামর্শ (৩৩৩)' : 'Government Info & Help (333)',
                  subtitle: isBn ? 'সরকারি কর্মকর্তা, সেবা ও সামাজিক সমস্যা সমাধান' : 'Citizen services and official information',
                  color: const Color(0xFF00796B),
                ),
                const SizedBox(height: 12),

                // Kushtia Police Lines
                _primaryCallCard(
                  number: '01320148098',
                  title: isBn ? 'কুষ্টিয়া জেলা পুলিশ কন্ট্রোল রুম' : 'Kushtia Police Lines Control Room',
                  subtitle: isBn ? 'জেলা পুলিশের সার্বক্ষণিক জরুরি নিরাপত্তা কেন্দ্র' : '24/7 District Police Headquarters Control Room',
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(height: 12),

                // Kushtia Fire Station
                _primaryCallCard(
                  number: '01901022877',
                  title: isBn ? 'কুষ্টিয়া সদর ফায়ার স্টেশন' : 'Kushtia Fire Station',
                  subtitle: isBn ? 'কুষ্টিয়া সদরের জন্য ফায়ার ও সিভিল ডিফেন্স' : 'Sadar Fire & Civil Defence Station',
                  color: const Color(0xFFD84315),
                ),
              ],
            ),
          ),

          // Tab 2: All 17 National Hotlines
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: hotlines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final hl = hotlines[index];
              return InkWell(
                onTap: () => _showHotlineDetails(context, hl, isBn),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hl.hotline,
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hl.getServiceName(isBn),
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hl.getPurpose(isBn),
                                style: AppTypography.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CallButton(phoneNumber: hl.hotline, compact: true),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Tab 3: Police & Fire Stations from Master Records
          recordsAsync.when(
            data: (records) {
              final emergencyRecords = records
                  .where((r) => r.categoryId == 'police' || r.categoryId == 'fire')
                  .toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                itemCount: emergencyRecords.length,
                itemBuilder: (context, index) {
                  final record = emergencyRecords[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Tpl01DirectoryCard(
                      record: record,
                      margin: EdgeInsets.zero,
                      onTap: () => RecordDetailScreen.open(context, record),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(l10n.networkError)),
          ),
        ],
      ),
    );
  }

  Widget _primaryCallCard({
    required String number,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emergency_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: AppTypography.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CallButton(phoneNumber: number, isPrimary: true),
        ],
      ),
    );
  }

  void _showHotlineDetails(BuildContext context, NationalHotline hl, bool isBn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  ),
                  child: Text(
                    hl.hotline,
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
                VerificationBadge(status: hl.verificationStatus),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hl.getServiceName(isBn),
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${hl.category} • ${isBn ? "কভারেজ: সারা দেশব্যাপী" : "Coverage: Nationwide"}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              isBn ? 'সেবার বিবরণ ও উদ্দেশ্য:' : 'Service Purpose & Details:',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hl.getPurpose(isBn),
              style: AppTypography.bodyMedium.copyWith(height: 1.5),
            ),
            if (hl.secondary != null && hl.secondary!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${isBn ? "বিকল্প নম্বর:" : "Alternative Contact:"} ${hl.secondary}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CallButton(
                    phoneNumber: hl.hotline,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
