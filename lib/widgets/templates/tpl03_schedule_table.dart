import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/railway_timetable_54_data.dart';
import '../../features/transport/train_live_tracking_screen.dart';
import '../../localization/app_localizations.dart';
import '../../models/transport_tables.dart';
import '../common/app_page_footer.dart';

/// TPL-03: Bangladesh Railway Western Zone Time Table No-54 (Effective: 10.03.2025)
/// Features interactive 2-sided route selection (From ➔ To), category filtering,
/// 12-hour friendly time formatting, weekly off-days, and direct official E-ticket portal.
class Tpl03ScheduleTable extends StatefulWidget {
  final List<TrainRecord> trains;
  final TransportSetting setting;
  final ScrollController? scrollController;

  const Tpl03ScheduleTable({
    super.key,
    required this.trains,
    required this.setting,
    this.scrollController,
  });

  @override
  State<Tpl03ScheduleTable> createState() => _Tpl03ScheduleTableState();
}

class _Tpl03ScheduleTableState extends State<Tpl03ScheduleTable> {
  String _fromStation = 'পোড়াদহ জংশন';
  String _toStation = 'সকল স্টেশন';
  String _selectedCategory = 'সকল';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedTrainNos = {};

  final List<String> _quickStations = const [
    'সকল স্টেশন',
    'কুষ্টিয়া কোর্ট',
    'পোড়াদহ জংশন',
    'ঢাকা',
    'খুলনা',
    'রাজশাহী',
    'ঈশ্বরদী',
    'বেনাপোল',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
    });
  }

  Future<void> _openTicketPortal() async {
    final uri = Uri.parse(widget.setting.onlineTicket.isNotEmpty
        ? widget.setting.onlineTicket
        : 'https://eticket.railway.gov.bd');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openLiveTracking(BuildContext context, String trainName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainLiveTrackingScreen(initialTrainName: trainName),
      ),
    );
  }

  List<WesternRailwayTrain> _getFilteredTrains() {
    final allTrains = RailwayTimetable54Data.trains;

    return allTrains.where((train) {
      // 1. Category Filter
      if (_selectedCategory != 'সকল' && train.category != _selectedCategory) {
        return false;
      }

      // 2. Search Query (Train No or Train Name)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchesNo = train.trainNo.toLowerCase().contains(query);
        final matchesName = train.trainName.toLowerCase().contains(query);
        final matchesStation = train.routeStations.any((s) => s.toLowerCase().contains(query));
        if (!matchesNo && !matchesName && !matchesStation) {
          return false;
        }
      }

      // 3. Route From ➔ To Matching
      final fromMatch = _fromStation == 'সকল স্টেশন' ? 'all' : _fromStation;
      final toMatch = _toStation == 'সকল স্টেশন' ? 'all' : _toStation;

      return train.matchesRoute(fromMatch, toMatch);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final filteredTrains = _getFilteredTrains();

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Timetable No. 54 Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF042B1A), Color(0xFF0B5233), Color(0xFF064E3B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF34D399).withAlpha(120)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 5),
                            Text(
                              isBn ? 'টাইম টেবিল নং-৫৪' : 'Time Table No-54',
                              style: GoogleFonts.googleSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isBn ? 'কার্যকর: ১০ মার্চ ২০২৫ ইং' : 'Effective: 10 March 2025',
                          style: GoogleFonts.googleSans(
                            color: Colors.white.withAlpha(200),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? 'পশ্চিমাঞ্চলের ট্রেনের সময়সূচি' : 'Western Zone Railway Timetable',
                    style: GoogleFonts.googleSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn
                        ? 'কুষ্টিয়া, পোড়াদহ, ঢাকা, খুলনা, রাজশাহী সহ পশ্চিমাঞ্চলের সকল ট্রেন'
                        : 'All trains across Kushtia, Poradah, Dhaka, Khulna, Rajshahi & Western Zone',
                    style: GoogleFonts.googleSans(
                      fontSize: 12.5,
                      color: Colors.white.withAlpha(210),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Official E-Ticket Action Banner ──
                InkWell(
                  onTap: _openTicketPortal,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF0B5233)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B5233).withAlpha(50),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.confirmation_num_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'অনলাইনে ট্রেনের টিকিট কাটুন' : 'Buy Railway E-Ticket Online',
                                style: GoogleFonts.googleSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'eticket.railway.gov.bd • বাংলাদেশ রেলওয়ে অফিসিয়াল পোর্টাল',
                                style: GoogleFonts.googleSans(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                isBn ? 'ই-টিকিট' : 'E-Ticket',
                                style: GoogleFonts.googleSans(
                                  color: const Color(0xFF0B5233),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.open_in_new_rounded, color: Color(0xFF0B5233), size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── 2. Interactive Route Selector (Two-Sided Dropdowns) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF5EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.route_rounded, color: Color(0xFF0B5233), size: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isBn ? 'রুট নির্বাচন (কোথা থেকে ➔ কোথায় যাবেন)' : 'Select Route (From ➔ To)',
                                style: GoogleFonts.googleSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          if (_fromStation != 'সকল স্টেশন' || _toStation != 'সকল স্টেশন')
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _fromStation = 'সকল স্টেশন';
                                  _toStation = 'সকল স্টেশন';
                                });
                              },
                              child: Text(
                                isBn ? 'রিসেট' : 'Reset',
                                style: GoogleFonts.googleSans(
                                  color: const Color(0xFFDC2626),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Station Selector Row
                      Row(
                        children: [
                          // FROM Dropdown
                          Expanded(
                            child: _buildStationDropdown(
                              label: isBn ? 'কোথা থেকে (উৎস)' : 'From (Origin)',
                              value: _fromStation,
                              color: const Color(0xFF059669),
                              icon: Icons.trip_origin_rounded,
                              onChanged: (val) {
                                if (val != null) setState(() => _fromStation = val);
                              },
                            ),
                          ),

                          // SWAP Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: InkWell(
                              onTap: _swapStations,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0B5233), size: 20),
                              ),
                            ),
                          ),

                          // TO Dropdown
                          Expanded(
                            child: _buildStationDropdown(
                              label: isBn ? 'কোথায় যাবেন (গন্তব্য)' : 'To (Destination)',
                              value: _toStation,
                              color: const Color(0xFFDC2626),
                              icon: Icons.location_on_rounded,
                              onChanged: (val) {
                                if (val != null) setState(() => _toStation = val);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Quick Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _quickStations.map((station) {
                            final isSelected = _fromStation == station || _toStation == station;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(station),
                                labelStyle: GoogleFonts.googleSans(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
                                ),
                                backgroundColor: isSelected ? const Color(0xFF0B5233) : const Color(0xFFF8FAFC),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF0B5233) : const Color(0xFFE2E8F0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                onPressed: () {
                                  setState(() {
                                    if (_fromStation == 'সকল স্টেশন') {
                                      _fromStation = station;
                                    } else {
                                      _toStation = station;
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── 3. Category Filter Tabs ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryTab('সকল', isBn ? 'সকল ট্রেন (${RailwayTimetable54Data.trains.length})' : 'All Trains'),
                      const SizedBox(width: 8),
                      _buildCategoryTab('আন্তঃনগর', isBn ? 'আন্তঃনগর এক্সপ্রেস' : 'Intercity'),
                      const SizedBox(width: 8),
                      _buildCategoryTab('মেইল ও কমিউটার', isBn ? 'মেইল ও কমিউটার' : 'Mail & Commuter'),
                      const SizedBox(width: 8),
                      _buildCategoryTab('লোকাল ও শাটল', isBn ? 'লোকাল ও শাটল' : 'Local & Shuttle'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── 4. Search Bar ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.googleSans(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'ট্রেন নম্বর বা নাম খুঁজুন (যেমন: ৭১৫, কপোতাক্ষ, সুন্দরবন)...'
                          : 'Search train number or name (e.g. 715, Sundarban)...',
                      hintStyle: GoogleFonts.googleSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0B5233), size: 20),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Results Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn
                          ? '${filteredTrains.length} টি ট্রেনের সময়সূচি প্রদর্শিত'
                          : '${filteredTrains.length} trains found',
                      style: GoogleFonts.googleSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    Text(
                      isBn ? '১০ মার্চ ২০২৫ অনুসারে' : 'As per 10 Mar 2025',
                      style: GoogleFonts.googleSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── 5. Train Cards List ──
                if (filteredTrains.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.train_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          isBn
                              ? 'নির্বাচিত রুটে কোনো ট্রেন পাওয়া যায়নি'
                              : 'No trains found for selected route',
                          style: GoogleFonts.googleSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'উৎস ও গন্তব্য পরিবর্তন করুন অথবা সকল ট্রেন নির্বাচন করুন।'
                              : 'Try changing Origin or Destination station to "All Stations".',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.googleSans(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _fromStation = 'সকল স্টেশন';
                              _toStation = 'সকল স্টেশন';
                              _selectedCategory = 'সকল';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: Text(isBn ? 'সকল ট্রেন দেখুন' : 'View All Trains'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTrains.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final train = filteredTrains[index];
                      final isExpanded = _expandedTrainNos.contains(train.trainNo);

                      return _buildTrainCard(train, isExpanded, isBn);
                    },
                  ),

                const SizedBox(height: 28),
              ],
            ),
          ),

          // ── App Footer ──
          const AppPageFooter(),
        ],
      ),
    );
  }

  Widget _buildStationDropdown({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.googleSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0B5233), size: 22),
              items: RailwayTimetable54Data.stations.map((s) {
                return DropdownMenuItem<String>(
                  value: s,
                  child: Text(
                    s,
                    style: GoogleFonts.googleSans(
                      fontSize: 12.5,
                      fontWeight: s == value ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(String id, String label) {
    final isSelected = _selectedCategory == id;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B5233) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B5233) : const Color(0xFFCBD5E1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0B5233).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.googleSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainCard(WesternRailwayTrain train, bool isExpanded, bool isBn) {
    final hasKushtiaStop = train.kushtiaPoradahStop != null && train.kushtiaPoradahStop!.isNotEmpty;
    final isNoOffDay = train.offDay.contains('নেই') || train.offDay == '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasKushtiaStop
              ? const Color(0xFF0B5233).withAlpha(45)
              : const Color(0xFFE2E8F0),
          width: hasKushtiaStop ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasKushtiaStop
                  ? const Color(0xFFEAF5EE).withAlpha(120)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Train Number Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B5233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          train.trainNo,
                          style: GoogleFonts.googleSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Train Name
                      Expanded(
                        child: Text(
                          train.trainName,
                          style: GoogleFonts.googleSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Off-day Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isNoOffDay
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNoOffDay
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isNoOffDay ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                        size: 11,
                        color: isNoOffDay ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isNoOffDay ? (isBn ? 'ছুটি নেই' : 'Daily') : (isBn ? 'ছুটি: ${train.offDay}' : 'Off: ${train.offDay}'),
                        style: GoogleFonts.googleSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isNoOffDay ? const Color(0xFF059669) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Route & Schedule Display ──
                Row(
                  children: [
                    // Origin
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            train.originStation,
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            train.departureTime12,
                            style: GoogleFonts.googleSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B5233),
                            ),
                          ),
                          Text(
                            '[${train.departureTime24}]',
                            style: GoogleFonts.googleSans(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow & Category
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              train.category,
                              style: GoogleFonts.googleSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 20, height: 1.5, color: const Color(0xFFCBD5E1)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.train_rounded, size: 14, color: Color(0xFF0B5233)),
                              ),
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0B5233)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Destination
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            train.destinationStation,
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            train.arrivalTime12,
                            style: GoogleFonts.googleSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                          Text(
                            '[${train.arrivalTime24}]',
                            style: GoogleFonts.googleSans(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Kushtia / Poradah Stoppage Callout (If applicable) ──
                if (hasKushtiaStop) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF86EFAC).withAlpha(150)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, size: 15, color: Color(0xFF0B5233)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            train.kushtiaPoradahStop!,
                            style: GoogleFonts.googleSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Expandable Intermediate Stations ──
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  Text(
                    isBn ? 'যাত্রাপথের প্রধান স্টেশনসমূহ:' : 'Key Intermediate Stations:',
                    style: GoogleFonts.googleSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: train.routeStations.map((st) {
                      final isKushtiaArea = st.contains('কুষ্টিয়া') || st.contains('পোড়াদহ') || st.contains('কুমারখালী') || st.contains('খোকসা') || st.contains('ভেড়ামারা');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isKushtiaArea ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isKushtiaArea ? const Color(0xFF34D399) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          st,
                          style: GoogleFonts.googleSans(
                            fontSize: 10.5,
                            fontWeight: isKushtiaArea ? FontWeight.w700 : FontWeight.w500,
                            color: isKushtiaArea ? const Color(0xFF065F46) : const Color(0xFF334155),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (train.routeDescription != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      train.routeDescription!,
                      style: GoogleFonts.googleSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 10),

                // ── Card Bottom Actions (Expand Stations, SMS Tracking, Buy Ticket) ──
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // View Route Stations Toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedTrainNos.remove(train.trainNo);
                          } else {
                            _expandedTrainNos.add(train.trainNo);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded ? (isBn ? 'স্টেশন লুকান' : 'Hide Stops') : (isBn ? 'স্টেশন তালিকা' : 'View Stops'),
                            style: GoogleFonts.googleSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B5233),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: const Color(0xFF0B5233),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Live Train Tracking Button
                        InkWell(
                          onTap: () => _openLiveTracking(context, train.trainName),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.radar_rounded, size: 14, color: Color(0xFF1D4ED8)),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? 'লাইভ ট্র্যাক' : 'Live Track',
                                  style: GoogleFonts.googleSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Direct E-Ticket Button
                        ElevatedButton.icon(
                          onPressed: _openTicketPortal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B5233),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.confirmation_num_outlined, size: 13),
                          label: Text(
                            isBn ? 'টিকিট কাটুন' : 'Tickets',
                            style: GoogleFonts.googleSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
    );
  }
}
