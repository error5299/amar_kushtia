import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_localizations.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../widgets/templates/tpl01_directory_card.dart';
import '../../widgets/templates/tpl05_product_card.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  final String? title;

  const DirectoryScreen({
    super.key,
    this.initialCategory = 'all',
    this.title,
  });

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  late String _selectedCategory;
  String _selectedUpazila = 'all';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final upazilas = ref.watch(upazilasProvider);

    final categories = [
      {'id': 'all', 'name': l10n.catAll},
      {'id': 'emergency', 'name': l10n.catEmergency},
      {'id': 'healthcare', 'name': l10n.catHealthcare},
      {'id': 'police', 'name': l10n.catPolice},
      {'id': 'fire', 'name': l10n.catFire},
      {'id': 'transport', 'name': l10n.catTransport},
      {'id': 'tourism', 'name': l10n.catTourism},
      {'id': 'government', 'name': l10n.catGovernment},
      {'id': 'education', 'name': l10n.catEducation},
      {'id': 'food', 'name': l10n.catFood},
      {'id': 'craft', 'name': l10n.catCraft},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.navDirectory),
      ),
      body: recordsAsync.when(
        data: (allRecords) {
          // Apply filters
          var filtered = allRecords;
          if (_selectedCategory != 'all') {
            filtered = filtered
                .where((r) => r.categoryId.toLowerCase() == _selectedCategory.toLowerCase())
                .toList();
          }
          if (_selectedUpazila != 'all') {
            filtered = filtered.where((r) => r.upazilaId == _selectedUpazila).toList();
          }

          return Column(
            children: [
              // Category Horizontal Filter Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat['name']!),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat['id']!;
                            });
                          },
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: AppColors.background,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          ),
                          labelStyle: AppTypography.labelMedium.copyWith(
                            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Upazila Sub-Filter Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _upazilaPill('all', l10n.allUpazilas),
                      ...upazilas.map((u) => _upazilaPill(u.id, u.getName(isBn))),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // Results Count Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} ${isBn ? "টি তথ্য পাওয়া গেছে" : "records found"}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Records List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(l10n.emptyCategory, style: AppTypography.bodyMedium),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final record = filtered[index];

                          if (record.categoryId == 'food' || record.categoryId == 'craft') {
                            return Tpl05ProductCard(
                              record: record,
                              onTap: () => RecordDetailScreen.open(context, record),
                            );
                          }

                          return Tpl01DirectoryCard(
                            record: record,
                            onTap: () => RecordDetailScreen.open(context, record),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text(l10n.networkError)),
      ),
    );
  }

  Widget _upazilaPill(String id, String label) {
    final isSelected = _selectedUpazila == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedUpazila = id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
