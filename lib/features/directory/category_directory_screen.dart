import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_localizations.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../widgets/templates/tpl01_directory_card.dart';
import '../../widgets/templates/tpl05_product_card.dart';

class CategoryDirectoryScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? themeColor;

  const CategoryDirectoryScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.subtitle,
    this.icon,
    this.themeColor,
  });

  @override
  ConsumerState<CategoryDirectoryScreen> createState() => _CategoryDirectoryScreenState();
}

class _CategoryDirectoryScreenState extends ConsumerState<CategoryDirectoryScreen> {
  String _selectedUpazila = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final upazilas = ref.watch(upazilasProvider);
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final color = widget.themeColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B5233),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.cardBorder, height: 1),
        ),
      ),
      body: recordsAsync.when(
        data: (allRecords) {
          // Filter strictly by this category
          var categoryRecords = allRecords
              .where((r) => r.categoryId.toLowerCase() == widget.categoryId.toLowerCase())
              .toList();

          // Upazila filter
          if (_selectedUpazila != 'all') {
            categoryRecords = categoryRecords
                .where((r) => r.upazilaId == _selectedUpazila)
                .toList();
          }

          // Search query filter within this category
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            categoryRecords = categoryRecords.where((r) {
              final nameBn = r.nameBn.toLowerCase();
              final nameEn = (r.nameEn ?? '').toLowerCase();
              final addrBn = (r.addressBn ?? '').toLowerCase();
              final phone = (r.phonePrimary ?? '').toLowerCase();
              final keywordsBn = r.searchKeywordsBn.join(' ').toLowerCase();
              return nameBn.contains(query) ||
                  nameEn.contains(query) ||
                  addrBn.contains(query) ||
                  phone.contains(query) ||
                  keywordsBn.contains(query);
            }).toList();
          }

          return Column(
            children: [
              // Search Bar & Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: isBn
                              ? '${widget.title}-এ খুঁজুন...'
                              : 'Search in ${widget.title}...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13.5,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: color, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Upazila Filter Chips Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _upazilaChip('all', l10n.allUpazilas, color),
                      ...upazilas.map((u) => _upazilaChip(u.id, u.getName(isBn), color)),
                    ],
                  ),
                ),
              ),

              Container(
                height: 1,
                color: const Color(0xFFE5E7EB),
              ),

              // Summary Counter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${categoryRecords.length} ${isBn ? "টি সেবা পাওয়া গেছে" : "services found"}',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedUpazila != 'all')
                      InkWell(
                        onTap: () => setState(() => _selectedUpazila = 'all'),
                        child: Text(
                          isBn ? 'ফিল্টার রিসেট' : 'Reset Filter',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Category Records List
              Expanded(
                child: categoryRecords.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon ?? Icons.info_outline_rounded,
                                  size: 44,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                isBn
                                    ? 'এই উপজেলায় কোনো তথ্য পাওয়া যায়নি'
                                    : 'No information available for this upazila',
                                style: AppTypography.titleMedium.copyWith(
                                  color: const Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isBn
                                    ? 'অন্য উপজেলা নির্বাচন করুন অথবা সকল উপজেলা দেখুন।'
                                    : 'Try selecting a different upazila or reset filter.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: categoryRecords.length,
                        itemBuilder: (context, index) {
                          final record = categoryRecords[index];

                          if (record.categoryId == 'food' || record.categoryId == 'craft') {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Tpl05ProductCard(
                                record: record,
                                margin: EdgeInsets.zero,
                                onTap: () => RecordDetailScreen.open(context, record),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Tpl01DirectoryCard(
                              record: record,
                              margin: EdgeInsets.zero,
                              onTap: () => RecordDetailScreen.open(context, record),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            isBn ? 'তথ্য লোড করতে ব্যর্থ হয়েছে' : 'Failed to load services',
            style: AppTypography.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _upazilaChip(String id, String label, Color themeColor) {
    final isSelected = _selectedUpazila == id;
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
