import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_typography.dart';
import '../../widgets/templates/record_detail_screen.dart';

class TourismScreen extends ConsumerStatefulWidget {
  const TourismScreen({super.key});

  @override
  ConsumerState<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends ConsumerState<TourismScreen>
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

  // Curated hero photography for top Kushtia landmarks
  String _getRepresentativeImage(MasterRecord record) {
    if (record.imageUrls.isNotEmpty && record.imageUrls.first.startsWith('http')) {
      return record.imageUrls.first;
    }
    final nameLower = (record.nameEn ?? record.nameBn).toLowerCase();
    if (nameLower.contains('shilaidaha') || nameLower.contains('শিলাইদহ') || nameLower.contains('কুঠিবাড়ি')) {
      return 'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800&q=80';
    } else if (nameLower.contains('lalon') || nameLower.contains('লালন')) {
      return 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=800&q=80';
    } else if (nameLower.contains('hardinge') || nameLower.contains('হার্ডিঞ্জ')) {
      return 'https://images.unsplash.com/photo-1545156521-77bd85671d30?w=800&q=80';
    } else if (nameLower.contains('harinath') || nameLower.contains('হরিনাথ')) {
      return 'https://images.unsplash.com/photo-1582650625119-3a31f8418b7d?w=800&q=80';
    } else if (nameLower.contains('gorai') || nameLower.contains('গড়াই')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80';
    } else if (record.categoryId == 'food') {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80';
    } else if (record.categoryId == 'craft') {
      return 'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final upazilas = ref.watch(upazilasProvider);
    final recordsAsync = ref.watch(masterRecordsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isBn ? 'কুষ্টিয়ার দর্শনীয় স্থান' : 'Kushtia Heritage & Places',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 3,
          labelColor: const Color(0xFFD97706),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.castle_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(isBn ? 'দর্শনীয় স্থান ও স্থাপনা' : 'Heritage & Places'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(isBn ? 'বিখ্যাত জিআই পণ্য' : 'GI Products'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: recordsAsync.when(
        data: (records) {
          var tourismPlaces = records.where((r) => r.categoryId == 'tourism').toList();
          var giProducts = records.where((r) => r.categoryId == 'food' || r.categoryId == 'craft').toList();

          if (_selectedUpazila != 'all') {
            tourismPlaces = tourismPlaces.where((r) => r.upazilaId == _selectedUpazila).toList();
            giProducts = giProducts.where((r) => r.upazilaId == _selectedUpazila).toList();
          }

          return Column(
            children: [
              // Upazila Filter Chips Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
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

              Container(height: 1, color: const Color(0xFFE2E8F0)),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Heritage & Places (Fully Redesigned Modern Visual Cards)
                    tourismPlaces.isEmpty
                        ? _emptyState(isBn)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            itemCount: tourismPlaces.length,
                            itemBuilder: (context, index) {
                              final record = tourismPlaces[index];
                              return _buildRedesignedHeritageCard(record, isBn);
                            },
                          ),

                    // Tab 2: GI Products
                    giProducts.isEmpty
                        ? _emptyState(isBn)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            itemCount: giProducts.length,
                            itemBuilder: (context, index) {
                              final record = giProducts[index];
                              return _buildRedesignedProductCard(record, isBn);
                            },
                          ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD97706)),
        ),
        error: (err, stackTrace) => Center(child: Text(l10n.networkError)),
      ),
    );
  }

  /// Fully Redesigned Premium Heritage Card with Hero Image, Gradient Overlay, & Modern Badges
  Widget _buildRedesignedHeritageCard(MasterRecord record, bool isBn) {
    final imageUrl = _getRepresentativeImage(record);
    final upazila = ref.watch(upazilasProvider).firstWhere(
          (u) => u.id == record.upazilaId,
          orElse: () => ref.watch(upazilasProvider).first,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => RecordDetailScreen.open(context, record),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Gradient Overlay & Status Tag
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFFEF3C7),
                      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFFD97706), size: 36),
                    ),
                  ),
                ),
                // Gradient Scrim for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(50),
                          Colors.transparent,
                          Colors.black.withAlpha(160),
                        ],
                      ),
                    ),
                  ),
                ),
                // Upazila Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xFFFBBF24), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          upazila.getName(isBn),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category / Subcategory Badge
                if (record.subcategoryId != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFB45309)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        record.subcategoryId!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Bottom Title inside image for instant punch
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Text(
                    record.getName(isBn),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 1)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Short Description
                  Text(
                    record.getShortDescription(isBn).isNotEmpty
                        ? record.getShortDescription(isBn)
                        : (record.getDescription(isBn)),
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Info Chips (Address & Fee/Hours)
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.getAddress(isBn).isNotEmpty
                              ? record.getAddress(isBn)
                              : upazila.getName(isBn),
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (record.feeType != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.feeAmount != null && record.feeAmount! > 0
                                ? '৳${record.feeAmount!.toInt()}'
                                : (isBn ? 'ফ্রি প্রবেশ' : 'Free Entry'),
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),

                  // Bottom Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'প্রত্নতত্ত্ব ও পর্যটন সাইট' : 'Heritage Site',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF059669),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            isBn ? 'বিস্তারিত দেখুন' : 'View Details',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Redesigned GI Product Card
  Widget _buildRedesignedProductCard(MasterRecord record, bool isBn) {
    final imageUrl = _getRepresentativeImage(record);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => RecordDetailScreen.open(context, record),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFFE2E8F0)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFFEF3C7),
                      child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBn ? 'জিআই পণ্য' : 'GI PRODUCT',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.getName(isBn),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.getShortDescription(isBn).isNotEmpty
                          ? record.getShortDescription(isBn)
                          : record.getDescription(isBn),
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _upazilaChip(String id, String label) {
    final isSelected = _selectedUpazila == id;
    const themeColor = Color(0xFFD97706);
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
        selectedColor: themeColor.withAlpha(25),
        backgroundColor: const Color(0xFFF1F5F9),
        side: BorderSide(
          color: isSelected ? themeColor : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
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

  Widget _emptyState(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.castle_outlined, size: 50, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              isBn ? 'এই উপজেলায় কোনো তথ্য পাওয়া যায়নি' : 'No places found in this upazila',
              style: AppTypography.titleMedium.copyWith(color: const Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}
