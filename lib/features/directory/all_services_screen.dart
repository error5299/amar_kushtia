import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/service_category.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'category_directory_screen.dart';
import '../emergency/emergency_screen.dart';
import '../healthcare/healthcare_screen.dart';
import '../map/district_atlas_screen.dart';
import '../tourism/tourism_screen.dart';
import '../transport/transport_screen.dart';
import '../transport/travel_guide_screen.dart';

class AllServicesScreen extends ConsumerStatefulWidget {
  const AllServicesScreen({super.key});

  @override
  ConsumerState<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends ConsumerState<AllServicesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _navigateToCategory(BuildContext context, ServiceCategory cat, bool isBn) {
    switch (cat.id.toLowerCase()) {
      case 'emergency':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
        break;
      case 'healthcare':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthcareScreen()));
        break;
      case 'transport':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
        break;
      case 'tourism':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TourismScreen()));
        break;
      case 'atlas':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DistrictAtlasScreen()));
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDirectoryScreen(
              categoryId: cat.id,
              title: cat.getTitle(isBn),
              subtitle: cat.getSubtitle(isBn).isNotEmpty ? cat.getSubtitle(isBn) : null,
              icon: cat.icon,
              themeColor: cat.color,
            ),
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.valueOrNull ?? SeedMasterData.defaultCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text(
          isBn ? 'সকল সেবা ও বিভাগসমূহ' : 'All Services & Categories',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
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
        data: (records) {
          // Filter categories by search query if typed
          var displayedCategories = categories;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            displayedCategories = categories.where((cat) {
              return cat.titleBn.toLowerCase().contains(query) ||
                  cat.titleEn.toLowerCase().contains(query) ||
                  cat.subtitleBn.toLowerCase().contains(query) ||
                  cat.subtitleEn.toLowerCase().contains(query) ||
                  cat.id.toLowerCase().contains(query);
            }).toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Box dedicated to Services & Categories
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(4),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                          ? 'সেবা ও বিভাগগুলোর মধ্যে খুঁজুন (যেমন: পুলিশ, ফায়ার...)'
                          : 'Search services (e.g. Police, Fire, Train...)',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0B5233),
                        size: 20,
                      ),
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

                const SizedBox(height: 12),

                // 2. Summary Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F0E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: Color(0xFF0B5233),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? '${displayedCategories.length}টি বিভাগ • নির্দিষ্ট ডিরেক্টরিতে উপজেলা ফিল্টার বিদ্যমান'
                              : '${displayedCategories.length} Categories • Dedicated Upazila Filtering',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2.2 Travel Guide Quick Banner
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TravelGuideScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B5233), Color(0xFF059669)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B5233).withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.explore_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'কুষ্টিয়া ভ্রমণ গাইড (Travel Guide)' : 'Kushtia Travel Guide',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                isBn
                                    ? 'লোকাল বাসের ভাড়া তালিকা ও দূরপাল্লার বাসের কাউন্টার'
                                    : 'Local bus fare list & long-distance bus counters',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Compact 4-Column Grid fitting all icons on one screen
                displayedCategories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            isBn
                                ? '"$_searchQuery" নামে কোনো বিভাগ বা সেবা পাওয়া যায়নি'
                                : 'No matching service found for "$_searchQuery"',
                            style: AppTypography.bodyMedium.copyWith(color: const Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: displayedCategories.length,
                        itemBuilder: (context, index) {
                          final cat = displayedCategories[index];
                          final count = cat.id == 'all'
                              ? records.length
                              : cat.id == 'atlas'
                                  ? 6
                                  : records
                                      .where((r) => r.categoryId.toLowerCase() == cat.id)
                                      .length;

                          return InkWell(
                            onTap: () => _navigateToCategory(context, cat, isBn),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Compact Icon with badge
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: cat.bgColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: cat.color.withAlpha(45),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          cat.icon,
                                          size: 20,
                                          color: cat.color,
                                        ),
                                      ),
                                      if (count > 0)
                                        Positioned(
                                          top: -3,
                                          right: -5,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4.5,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: cat.color,
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Text(
                                              '$count',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Category Label
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      isBn ? cat.titleBn : cat.titleEn,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: const Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.5,
                                        height: 1.15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 16),
              ],
            ),
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
}
