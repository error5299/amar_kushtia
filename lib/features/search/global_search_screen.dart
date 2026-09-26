import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/templates/record_detail_screen.dart';
import '../../widgets/templates/tpl01_directory_card.dart';
import '../../widgets/templates/tpl05_product_card.dart';
import '../transport/travel_guide_screen.dart';

/// Clean, Focused Universal Search Screen for Amar Kushtia.
/// Simple and distraction-free: no cluttered filter bars or upazila chips.
/// Full-width edge-to-edge cards matching the rest of the application.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  final List<MasterRecord>? allRecords;
  final String? initialQuery;

  const GlobalSearchScreen({
    super.key,
    this.allRecords,
    this.initialQuery,
  });

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _query = '';

  // Minimal quick suggestion pills
  final List<String> _quickSuggestionsBn = [
    'ভ্রমণ গাইড',
    'বাস ভাড়া',
    'ঢাকা বাস',
    'হাসপাতাল',
    'থানা',
    'ফায়ার সার্ভিস',
    'শিলাইদহ কুঠিবাড়ি',
    'লালন মাজার',
    'হার্ডিঞ্জ ব্রিজ',
    'ট্রেন',
    'বাস কাউন্টার',
    'তিলের খাজা',
    'কুমারখালী তাঁত',
    'ডাক্তার',
  ];

  final List<String> _quickSuggestionsEn = [
    'Travel Guide',
    'Bus Fare',
    'Dhaka Bus',
    'Hospital',
    'Police',
    'Fire Service',
    'Shilaidaha',
    'Lalon Shrine',
    'Hardinge Bridge',
    'Train',
    'Bus',
    'Tiler Khaja',
    'Kumarkhali Handloom',
    'Doctor',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _query);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {
      _query = value;
    });
  }

  void _setSearchTerm(String term) {
    _searchController.text = term;
    setState(() {
      _query = term;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final repo = ref.watch(recordsRepositoryProvider);
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final suggestions = isBn ? _quickSuggestionsBn : _quickSuggestionsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0B5233),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4EADB), width: 1.1),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF0B5233),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearch,
                    style: GoogleFonts.googleSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'কী খুঁজতে চান? সেবা, হাসপাতাল, স্থান বা নাম লিখুন...'
                          : 'What are you looking for? Search records...',
                      hintStyle: GoogleFonts.googleSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: recordsAsync.when(
        data: (allData) {
          final dataPool = widget.allRecords ?? allData;

          final list = _query.trim().isEmpty
              ? dataPool
              : repo.searchRecords(dataPool, _query);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean horizontal suggestion chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: suggestions.map((tag) {
                      final isSelected = _query.trim() == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            if (isSelected) {
                              _setSearchTerm('');
                            } else {
                              _setSearchTerm(tag);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0B5233)
                                  : const Color(0xFFEAF5EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0B5233)
                                    : const Color(0xFFBCE3C9),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.googleSans(
                                color: isSelected ? Colors.white : const Color(0xFF0B5233),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Header: Results Counter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _query.trim().isNotEmpty
                          ? (isBn
                              ? '"$_query"-এর জন্য ${list.length}টি ফলাফল'
                              : 'Results for "$_query" (${list.length})')
                          : (isBn
                              ? 'সকল তথ্য ও সেবাসমূহ (${list.length}টি)'
                              : 'All Services & Records (${list.length})'),
                      style: GoogleFonts.googleSans(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (_query.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            isBn ? 'রিসেট' : 'Clear',
                            style: GoogleFonts.googleSans(
                              color: const Color(0xFF0B5233),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Search Results List (margin: EdgeInsets.zero on cards, single 14px listview padding)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final q = _query.toLowerCase().trim();
                    final isTravelQuery = q.isNotEmpty &&
                        (q.contains('বাস') ||
                            q.contains('ভাড়া') ||
                            q.contains('ভ্রমণ') ||
                            q.contains('ঢাকা') ||
                            q.contains('মেহেরপুর') ||
                            q.contains('চুয়াডাঙ্গা') ||
                            q.contains('খুলনা') ||
                            q.contains('শ্যামলী') ||
                            q.contains('হানিফ') ||
                            q.contains('কাউন্টার') ||
                            q.contains('গাইড') ||
                            q.contains('bus') ||
                            q.contains('fare') ||
                            q.contains('travel') ||
                            q.contains('dhaka') ||
                            q.contains('route'));

                    final totalCount = list.length + (isTravelQuery ? 1 : 0);

                    if (totalCount == 0) {
                      return _buildEmptyState(context, isBn, suggestions);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
                        if (isTravelQuery && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TravelGuideScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF86EFAC),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF059669),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.explore_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                isBn
                                                    ? 'কুষ্টিয়া ভ্রমণ গাইড'
                                                    : 'Kushtia Travel Guide',
                                                style: GoogleFonts.googleSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.5,
                                                  color: const Color(0xFF065F46),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF059669),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isBn ? 'নতুন সেবা' : 'Feature',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            isBn
                                                ? 'লোকাল বাস ভাড়া ক্যালকুলেটর ও দূরপাল্লার বাসের টিকিট কাউন্টার'
                                                : 'Local bus fare calculator & long-distance bus counters',
                                            style: GoogleFonts.googleSans(
                                              fontSize: 12,
                                              color: const Color(0xFF047857),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xFF059669),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final record = list[isTravelQuery ? index - 1 : index];

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
        error: (e, _) => Center(
          child: Text(
            isBn ? 'ডেটা লোড করতে সমস্যা হয়েছে।' : 'Failed to load search data.',
            style: GoogleFonts.googleSans(color: const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isBn,
    List<String> suggestions,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 46,
              color: Color(0xFF0B5233),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isBn ? 'কোনো তথ্য খুঁজে পাওয়া যায়নি' : 'No records found',
            style: GoogleFonts.googleSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'অন্য কোনো নাম লিখে সার্চ করুন অথবা নিচের যেকোনো টপিকে চাপুন:'
                : 'Try searching with another keyword or pick a topic below:',
            textAlign: TextAlign.center,
            style: GoogleFonts.googleSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((tag) {
              return ActionChip(
                label: Text(tag),
                backgroundColor: const Color(0xFFEAF5EE),
                side: const BorderSide(color: Color(0xFFBCE3C9), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                labelStyle: GoogleFonts.googleSans(
                  color: const Color(0xFF0B5233),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onPressed: () {
                  _setSearchTerm(tag);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
