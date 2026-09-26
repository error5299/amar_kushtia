import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../widgets/templates/tpl01_directory_card.dart';

class HealthcareScreen extends ConsumerStatefulWidget {
  const HealthcareScreen({super.key});

  @override
  ConsumerState<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends ConsumerState<HealthcareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedUpazila = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final upazilas = ref.watch(upazilasProvider);
    final bedFees = ref.watch(bedFeesProvider).valueOrNull ?? SeedMasterData.bedFees;
    final surgeries = ref.watch(surgerySchedulesProvider).valueOrNull ?? SeedMasterData.surgerySchedules;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text(
          isBn ? 'হাসপাতাল ও স্বাস্থ্যসেবা' : 'Healthcare & Hospitals',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B5233),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0284C7),
          indicatorWeight: 3,
          labelColor: const Color(0xFF0284C7),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: isBn ? 'সকল হাসপাতাল ও ক্লিনিক' : 'Hospitals & Clinics'),
            Tab(text: isBn ? 'সরকারি ফি ও সার্জারি' : 'Fees & Surgeries'),
          ],
        ),
      ),
      body: recordsAsync.when(
        data: (records) {
          // All healthcare records
          var healthRecords = records.where((r) => r.categoryId == 'healthcare').toList();

          // Upazila filtering for healthcare list
          if (_selectedUpazila != 'all') {
            healthRecords = healthRecords.where((r) => r.upazilaId == _selectedUpazila).toList();
          }

          final hospital250Bed = records.firstWhere(
            (r) => r.id == 'MD-0026',
            orElse: () => healthRecords.isNotEmpty ? healthRecords.first : records.first,
          );

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: All Healthcare List with Upazila Filter
              Column(
                children: [
                  // Upazila Filter Chips Bar
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          _upazilaChip('all', l10n.allUpazilas),
                          ...upazilas.map((u) => _upazilaChip(u.id, u.getName(isBn))),
                        ],
                      ),
                    ),
                  ),

                  Container(height: 1, color: const Color(0xFFE5E7EB)),

                  // Summary Counter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${healthRecords.length} ${isBn ? "টি স্বাস্থ্যসেবা ও ক্লিনিক পাওয়া গেছে" : "healthcare services found"}',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedUpazila != 'all')
                          InkWell(
                            onTap: () => setState(() => _selectedUpazila = 'all'),
                            child: const Text(
                              'রিসেট',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0284C7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // List of Hospitals and Health Complexes
                  Expanded(
                    child: healthRecords.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.local_hospital_outlined,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isBn
                                        ? 'এই উপজেলায় কোনো স্বাস্থ্যসেবা প্রতিষ্ঠান পাওয়া যায়নি'
                                        : 'No healthcare records found for this upazila',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: const Color(0xFF475569),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            itemCount: healthRecords.length,
                            itemBuilder: (context, index) {
                              final record = healthRecords[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Tpl01DirectoryCard(
                                  record: record,
                                  margin: EdgeInsets.zero,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RecordDetailScreen(record: record),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),

              // Tab 2: 250-Bed General Hospital Bed & Surgery Fees
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital Highlight Card
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecordDetailScreen(record: hospital250Bed),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                color: Color(0xFF0284C7),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hospital250Bed.getName(isBn),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isBn ? 'কুষ্টিয়ার প্রধান রেফারেল সরকারি হাসপাতাল' : 'Main referral hospital in Kushtia',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Bed Tariff Table
                    Text(
                      isBn ? '২৫০ শয্যা জেনারেল হাসপাতাল — বেড ও কেবিন ফি' : 'Bed & Cabin Tariff',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bedFees.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final fee = bedFees[index];
                          return ListTile(
                            title: Text(fee.bedType, style: AppTypography.titleSmall),
                            subtitle: Text('${fee.capacityUnit} • ${fee.dietNotes}', style: AppTypography.bodySmall),
                            trailing: Text(
                              fee.dailyRentBdt == 0 ? (isBn ? 'ফ্রি' : 'Free') : '৳${fee.dailyRentBdt.toInt()}',
                              style: AppTypography.titleMedium.copyWith(
                                color: const Color(0xFF0284C7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Surgery Schedule Table
                    Text(
                      isBn ? 'সার্জারি সূচি ও সরকারি ফি' : 'Surgery Schedule & Fees',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: surgeries.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = surgeries[index];
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      s.department,
                                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        s.surgeryDays,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: const Color(0xFF0284C7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isBn ? "মাইনর সার্জারি:" : "Minor:"} ৳${s.minorFee} | ${isBn ? "মেজর সার্জারি:" : "Major:"} ৳${s.majorFee}',
                                  style: AppTypography.bodySmall.copyWith(color: const Color(0xFF475569)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stackTrace) => Center(child: Text(l10n.networkError)),
      ),
    );
  }

  Widget _upazilaChip(String id, String label) {
    final isSelected = _selectedUpazila == id;
    const themeColor = Color(0xFF0284C7);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedUpazila = id;
          });
        },
        selectedColor: themeColor.withAlpha(30),
        backgroundColor: const Color(0xFFF1F5F9),
        side: BorderSide(
          color: isSelected ? themeColor : const Color(0xFFE2E8F0),
          width: isSelected ? 1.4 : 1,
        ),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? themeColor : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}
