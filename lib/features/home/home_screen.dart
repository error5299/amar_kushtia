import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../models/service_category.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/upazila.dart';
import '../../widgets/common/brand_logo.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../services/auth_provider.dart';
import '../directory/all_services_screen.dart';
import '../directory/category_directory_screen.dart';
import '../emergency/emergency_screen.dart';
import '../healthcare/healthcare_screen.dart';
import '../map/district_atlas_screen.dart';
import '../search/global_search_screen.dart';
import '../settings/settings_screen.dart';
import '../tourism/tourism_screen.dart';
import '../transport/transport_screen.dart';
import '../transport/travel_guide_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../services/notification_service.dart';
import '../../services/update_service.dart';
import '../../widgets/common/app_update_dialog.dart';
import '../../widgets/common/app_page_footer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _hasCheckedUpdate = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.hasClients && _scrollController.offset > 300;
      if (show != _showBackToTop) setState(() => _showBackToTop = show);
    });

    // Check for app update and prompt user immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptUpdate();
    });
  }

  Future<void> _checkAndPromptUpdate() async {
    if (_hasCheckedUpdate || !mounted) return;
    _hasCheckedUpdate = true;

    try {
      final latest = await UpdateService.instance.fetchLatestUpdate();
      if (!mounted || latest == null) return;

      if (UpdateService.instance.isUpdateAvailable(latest)) {
        final isBn = AppLocalizations.of(context).isBn;
        showAppUpdatePopupDialog(
          context: context,
          isBn: isBn,
          updateInfo: latest,
        );
      }
    } catch (e) {
      debugPrint('[HomeScreen] Update check error: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final upazilas = ref.watch(upazilasProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final List<ServiceCategory> allCategories =
        categoriesAsync.valueOrNull ?? SeedMasterData.defaultCategories;
    final List<ServiceCategory> displayCategories =
        allCategories.where((c) => c.isActive).take(9).toList();

    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              backgroundColor: const Color(0xFF0B5233),
              foregroundColor: Colors.white,
              tooltip: 'Back to top',
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        titleSpacing: 16,
        title: const BrandLogo(size: 28, showTagline: false),
        actions: [
          // Language Switcher (বাংলা | English)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              avatar: const Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
              label: Text(
                isBn ? 'English' : 'বাংলা',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              backgroundColor: AppColors.primaryContainer,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
            ),
          ),

          // Notification Bell Button with Unread Badge
          Consumer(
            builder: (context, ref, child) {
              final unreadCount = ref.watch(unreadNotificationCountProvider);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -3,
                          top: -3,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: isBn ? 'নোটিফিকেশন' : 'Notifications',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
              );
            },
          ),

          // User Google Profile Avatar Button (Visible when logged in, opens Settings)
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 14, left: 4),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0B5233),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: user.photoURL != null && user.photoURL!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.photoURL!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFE2F0E8),
                              child: const Icon(Icons.person, size: 18, color: Color(0xFF0B5233)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFE2F0E8),
                              child: const Icon(Icons.person, size: 18, color: Color(0xFF0B5233)),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFE2F0E8),
                            child: const Icon(Icons.person, size: 20, color: Color(0xFF0B5233)),
                          ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          final tourismSpots = records.where((r) => r.categoryId == 'tourism').toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(masterRecordsStreamProvider);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content wrapper with horizontal padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Persistent App Update Banner (Visible whenever an update is available until installed)
                  Consumer(
                    builder: (context, ref, child) {
                      final updateAsync = ref.watch(appUpdateInfoProvider);
                      final updateInfo = updateAsync.valueOrNull;
                      if (updateInfo == null || !UpdateService.instance.isUpdateAvailable(updateInfo)) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF59E0B).withAlpha(160)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isBn ? 'নতুন ভার্সন রিলিজ হয়েছে!' : 'New Version Released!',
                                        style: const TextStyle(
                                          fontFamily: AppTypography.primaryFont,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF78350F),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'v${updateInfo.latestVersion}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isBn
                                        ? 'নতুন সুবিধা পেতে এখনই অ্যাপটি আপডেট করে নিন।'
                                        : 'Update the app now to get the latest features.',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.primaryFont,
                                      fontSize: 11.5,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B5233),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                showAppUpdatePopupDialog(
                                  context: context,
                                  isBn: isBn,
                                  updateInfo: updateInfo,
                                );
                              },
                              child: Text(
                                isBn ? 'আপডেট' : 'Update',
                                style: const TextStyle(
                                  fontFamily: AppTypography.primaryFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 1. Minimal Clean Search Bar
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GlobalSearchScreen(allRecords: records),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF0B5233), size: 21),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isBn
                                  ? 'কুষ্টিয়ার সেবা, হাসপাতাল, থানা খুঁজুন...'
                                  : 'Search services, hospitals, police...',
                              style: AppTypography.bodyMedium.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Minimal Emergency Quick Banner
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFCA5A5).withAlpha(120)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBn ? 'জরুরি হেল্পলাইন (২৪/৭ ফ্রি কল)' : '24/7 Emergency Hotlines',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF991B1B),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  isBn ? '৯৯৯ (জাতীয়) • ১০২ (ফায়ার) • ৩৩৩ (সরকারি)' : '999 (National) • 102 (Fire) • 333 (Gov)',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFFB91C1C),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFDC2626), size: 14),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 2.5 Travel Guide Quick Banner
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TravelGuideScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF86EFAC).withAlpha(120)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBn ? 'কুষ্টিয়া ভ্রমণ গাইড (বাস ভাড়া ও কাউন্টার)' : 'Kushtia Travel Guide (Bus Fare & Counters)',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF065F46),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  isBn ? 'লোকাল বাস ভাড়া ক্যালকুলেটর • দূরপাল্লার বাসের টিকিট কাউন্টার' : 'Local bus fare calculator • Long-distance bus counters',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF047857),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF059669), size: 14),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Clean Services & Categories Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B5233), Color(0xFF15803D)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B5233).withAlpha(40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 17),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            isBn ? 'সেবাসমূহ ও বিভাগ' : 'Services & Categories',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllServicesScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF0B5233).withAlpha(40), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isBn ? 'সকল বিভাগ' : 'View All',
                                style: const TextStyle(
                                  fontFamily: AppTypography.primaryFont,
                                  color: Color(0xFF0B5233),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0B5233)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Futuristic Minimal Category Grid (3 Columns, Perfect Visibility & Subtitles)
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final cat = displayCategories[index];
                      return _categoryTile(
                        icon: cat.icon,
                        title: cat.getTitle(isBn),
                        subtitle: cat.getSubtitle(isBn),
                        color: cat.color,
                        bgColor: cat.bgColor,
                        onTap: () {
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
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AllServicesScreen()));
                              break;
                            default:
                              _openCategory(context, cat.id, cat.getTitle(isBn));
                              break;
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // 4. Spotlight: Top Kushtia Heritage (Clean Horizontal Cards)
                  if (tourismSpots.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'কুষ্টিয়ার দর্শনীয় স্থান' : 'Must-Visit Spots',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TourismScreen()),
                          ),
                          child: Text(
                            isBn ? 'আরও দেখুন' : 'See all',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF0B5233),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 175,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: tourismSpots.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final spot = tourismSpots[index];
                          return _spotlightSpotCard(spot, isBn);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 5. Kushtia at a Glance (কুষ্টিয়া এক নজরে — Futuristic Civic Banner)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF042B1A), Color(0xFF0B5233), Color(0xFF063B24)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B5233).withAlpha(45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF34D399).withAlpha(40), width: 1.2),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withAlpha(40)),
                                  ),
                                  child: const Icon(
                                    Icons.auto_stories_rounded,
                                    color: Color(0xFF34D399),
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isBn ? 'কুষ্টিয়া এক নজরে' : 'Kushtia at a Glance',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.primaryFont,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DistrictAtlasScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withAlpha(50)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      isBn ? 'ডিজিটাল মানচিত্র' : 'District Atlas',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.primaryFont,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withAlpha(18)),
                          ),
                          child: Row(
                            children: [
                              _glanceMetric(
                                isBn ? '৬টি' : '6',
                                isBn ? 'উপজেলা' : 'Upazilas',
                                Icons.location_city_rounded,
                              ),
                              Container(width: 1, height: 32, color: Colors.white.withAlpha(30)),
                              _glanceMetric(
                                isBn ? '১,৬২১' : '1,621',
                                isBn ? 'বর্গ কিমি' : 'Sq Km',
                                Icons.square_foot_rounded,
                              ),
                              Container(width: 1, height: 32, color: Colors.white.withAlpha(30)),
                              _glanceMetric(
                                isBn ? '২১.৫+' : '21.5L+',
                                isBn ? 'জনসংখ্যা' : 'Population',
                                Icons.people_alt_rounded,
                              ),
                              Container(width: 1, height: 32, color: Colors.white.withAlpha(30)),
                              _glanceMetric(
                                isBn ? 'পদ্মা-গড়াই' : 'Padma-Gorai',
                                isBn ? 'নদীনালা' : 'Rivers',
                                Icons.water_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 6. 6 Upazilas of Kushtia (কুষ্টিয়ার ৬টি উপজেলা)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'কুষ্টিয়ার ৬টি উপজেলা' : '6 Upazilas of Kushtia',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DistrictAtlasScreen(),
                            ),
                          );
                        },
                        child: Text(
                          isBn ? 'মানচিত্রে দেখুন ➔' : 'View on Map ➔',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF0B5233),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Clean 2-Column Grid of 6 Upazilas with generous text breathing room
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.10,
                    children: upazilas.map((u) {
                      return _upazilaGridCard(context, u, isBn);
                    }).toList(),
                  ),

                      const SizedBox(height: 32),
                      ], // inner content column children
                    ),   // inner Padding
                  ),     // outer Padding wrapper

                  // ── Illustrated Footer (full-width, outside padded column) ──
                  const AppPageFooter(),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.emergency, size: 48),
                const SizedBox(height: 12),
                Text(l10n.networkError, style: AppTypography.bodyMedium),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(masterRecordsStreamProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _categoryTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    Color? bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withAlpha(25),
        highlightColor: color.withAlpha(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withAlpha(35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor ?? color.withAlpha(30),
                      (bgColor ?? color).withAlpha(45),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.primaryFont,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFont,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _spotlightSpotCard(MasterRecord spot, bool isBn) {
    return InkWell(
      onTap: () => RecordDetailScreen.open(context, spot),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image cover
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _resolveSpotImage(spot),
                    httpHeaders: const {
                      'User-Agent':
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 AmarKushtia/1.0',
                    },
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primaryContainer,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryContainer,
                      child: const Icon(Icons.place_rounded, color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        spot.subcategoryId ?? 'Heritage',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.getName(isBn),
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          spot.getAddress(isBn),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  String _resolveSpotImage(MasterRecord spot) {
    if (spot.imageUrls.isNotEmpty) {
      return spot.imageUrls.first;
    }
    final id = spot.id;
    if (id.contains('41') || spot.nameEn?.toLowerCase().contains('shilaidaha') == true) {
      return 'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800&q=80';
    } else if (id.contains('42') || spot.nameEn?.toLowerCase().contains('lalon') == true) {
      return 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=800&q=80';
    } else if (id.contains('43') || spot.nameEn?.toLowerCase().contains('hardinge') == true) {
      return 'https://images.unsplash.com/photo-1545156521-77bd85671d30?w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800&q=80';
  }

  void _openCategory(BuildContext context, String categoryId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDirectoryScreen(
          categoryId: categoryId,
          title: title,
        ),
      ),
    );
  }

  Widget _glanceMetric(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xD2FFFFFF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _upazilaGridCard(BuildContext context, Upazila u, bool isBn) {
    String featureTag = '';
    IconData icon = Icons.location_on_rounded;
    final name = (u.nameBn + u.nameEn).toLowerCase();
    
    if (name.contains('সদর') || name.contains('sadar')) {
      featureTag = isBn ? 'প্রশাসনিক কেন্দ্র ও পৌরসভা' : 'Civic & District HQ';
      icon = Icons.account_balance_rounded;
    } else if (name.contains('কুমারখালী') || name.contains('kumarkhali')) {
      featureTag = isBn ? 'শিলাইদহ কুঠিবাড়ি ও তাঁত' : 'Kuthibari & Handloom';
      icon = Icons.castle_rounded;
    } else if (name.contains('ভেড়ামারা') || name.contains('ভেড়ামারা') || name.contains('bheramara')) {
      featureTag = isBn ? 'হার্ডিঞ্জ ব্রিজ ও বিদ্যুৎকেন্দ্র' : 'Hardinge Bridge & Power';
      icon = Icons.train_rounded;
    } else if (name.contains('মিরপুর') || name.contains('mirpur')) {
      featureTag = isBn ? 'পোড়াদহ জংশন ও কৃষি' : 'Poradah Junction & Agri';
      icon = Icons.alt_route_rounded;
    } else if (name.contains('দৌলতপুর') || name.contains('daulatpur')) {
      featureTag = isBn ? 'বৃহত্তম উপজেলা ও চরাঞ্চল' : 'Largest Area & Riverbed';
      icon = Icons.terrain_rounded;
    } else if (name.contains('খোকসা') || name.contains('khoksa')) {
      featureTag = isBn ? 'কালীপূজার মেলা ও মিষ্টি' : 'Fair, Crafts & Heritage';
      icon = Icons.festival_rounded;
    } else {
      featureTag = u.identityNotes.isNotEmpty ? u.identityNotes : (isBn ? 'কুষ্টিয়ার উপজেলা' : 'Upazila of Kushtia');
      icon = Icons.location_city_rounded;
    }

    return InkWell(
      onTap: () => _showUpazilaOverview(context, u, isBn, featureTag, icon),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0B5233).withAlpha(30), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5233).withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAF5EE), Color(0xFFD4EADB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B5233).withAlpha(20),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: const Color(0xFF0B5233), size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    isBn ? '${u.unionCount} ইউনিয়ন' : '${u.unionCount} Unions',
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFont,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.getName(isBn),
                  style: const TextStyle(
                    fontFamily: AppTypography.primaryFont,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  featureTag,
                  style: const TextStyle(
                    fontFamily: AppTypography.primaryFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B5233),
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpazilaOverview(
    BuildContext context,
    Upazila u,
    bool isBn,
    String featureTag,
    IconData icon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header with Upazila Name & Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: const Color(0xFF0B5233), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.getName(isBn),
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            featureTag,
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B5233),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Key Statistics Grid (আয়তন, জনসংখ্যা, ইউনিয়ন, পৌরসভা)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      _upazilaStatItem(
                        isBn ? 'আয়তন' : 'Area',
                        '${u.areaSqKm} ${isBn ? "বর্গ কিমি" : "sq km"}',
                        Icons.square_foot_rounded,
                      ),
                      Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                      _upazilaStatItem(
                        isBn ? 'জনসংখ্যা' : 'Population',
                        '${(u.population2022 / 100000).toStringAsFixed(1)}${isBn ? " লাখ" : "L"}',
                        Icons.people_outline_rounded,
                      ),
                      Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                      _upazilaStatItem(
                        isBn ? 'ইউনিয়ন' : 'Unions',
                        '${u.unionCount} ${isBn ? "টি" : ""}',
                        Icons.holiday_village_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Identity & Highlights Info Box
                if (u.identityNotes.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EE).withAlpha(160),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD4EADB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Color(0xFF0B5233),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            u.identityNotes,
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Action Buttons: View Services & View Location/Map
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5233),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.list_alt_rounded, size: 20),
                  label: Text(
                    isBn ? '${u.nameBn}-এর সকল সেবা ও জরুরি তালিকা' : 'View Services in ${u.nameEn}',
                    style: const TextStyle(fontFamily: AppTypography.primaryFont, fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllServicesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B5233),
                    side: const BorderSide(color: Color(0xFF0B5233), width: 1.2),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 19),
                  label: Text(
                    isBn ? 'উপজেলার মানচিত্র ও ভৌগোলিক তথ্য' : 'Upazila Map & Geography',
                    style: const TextStyle(fontFamily: AppTypography.primaryFont, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DistrictAtlasScreen(
                          initialUpazilaId: u.nameEn.toLowerCase(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _upazilaStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0B5233)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.primaryFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
