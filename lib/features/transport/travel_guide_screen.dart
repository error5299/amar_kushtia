import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/app_localizations.dart';
import '../../models/travel_guide_models.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'bus_operator_details_screen.dart';

class TravelGuideScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const TravelGuideScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<TravelGuideScreen> createState() => _TravelGuideScreenState();
}

class _TravelGuideScreenState extends ConsumerState<TravelGuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Local Bus State
  String? _selectedRouteId;
  String? _fromStopId;
  String? _toStopId;
  bool _showFullTimeline = false;

  // Long Distance Bus State
  String? _selectedDestinationId;
  final TextEditingController _destSearchController = TextEditingController();
  String _searchQuery = '';

  Widget _buildOperatorLogo(BusOperator operator) {
    if (operator.logoUrl != null && operator.logoUrl!.trim().isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(
            operator.logoUrl!.trim(),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildDefaultBusAvatar(),
          ),
        ),
      );
    }
    return _buildDefaultBusAvatar();
  }

  Widget _buildDefaultBusAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5638), Color(0xFF2E7D52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _destSearchController.addListener(() {
      setState(() {
        _searchQuery = _destSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _destSearchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isBn ? 'কুষ্টিয়া ভ্রমণ গাইড' : 'Kushtia Travel Guide',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(
              icon: const Icon(Icons.directions_bus, size: 20),
              text: isBn ? 'লোকাল বাস ও ভাড়া' : 'Local Bus Fare',
            ),
            Tab(
              icon: const Icon(Icons.alt_route_rounded, size: 20),
              text: isBn ? 'দূরপাল্লার বাস ও কাউন্টার' : 'Long-Distance Bus',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalBusTab(isBn),
          _buildLongDistanceTab(isBn),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: LOCAL BUS FARE CALCULATOR & TIMELINE
  // ==========================================
  Widget _buildLocalBusTab(bool isBn) {
    final routesAsync = ref.watch(localRoutesProvider);

    return routesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(
        child: Text(isBn ? 'তথ্য লোড করতে সমস্যা হয়েছে' : 'Failed to load routes: $e'),
      ),
      data: (routes) {
        if (routes.isEmpty) {
          return Center(
            child: Text(isBn ? 'কোনো লোকাল রুট পাওয়া যায়নি' : 'No local routes found'),
          );
        }

        // Auto select first route if none selected or invalid
        final activeRoute = routes.firstWhere(
          (r) => r.id == _selectedRouteId,
          orElse: () => routes.first,
        );

        if (_selectedRouteId != activeRoute.id) {
          _selectedRouteId = activeRoute.id;
          final stops = activeRoute.sortedStops;
          if (stops.isNotEmpty) {
            _fromStopId = stops.first.id;
            _toStopId = stops.length > 1 ? stops.last.id : stops.first.id;
          }
        }

        final stops = activeRoute.sortedStops;

        if (!stops.any((s) => s.id == _fromStopId) && stops.isNotEmpty) {
          _fromStopId = stops.first.id;
        }
        if (!stops.any((s) => s.id == _toStopId) && stops.isNotEmpty) {
          _toStopId = stops.length > 1 ? stops[1].id : stops.first.id;
        }

        final fare = (_fromStopId != null && _toStopId != null)
            ? activeRoute.calculateFare(_fromStopId!, _toStopId!)
            : null;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notice Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'কুষ্টিয়া ও পার্শ্ববর্তী অঞ্চলের বাস ভাড়ার প্রামাণ্য হিসাব।'
                          : 'Standard bus fare calculation for Kushtia & neighboring routes.',
                      style: GoogleFonts.googleSans(
                        fontSize: 12.5,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Selector Dropdown
            Text(
              isBn ? 'রুট নির্বাচন করুন' : 'Select Route',
              style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRouteId,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: routes.map((r) {
                    return DropdownMenuItem<String>(
                      value: r.id,
                      child: Text(
                        r.getTitle(isBn),
                        style: GoogleFonts.googleSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null && newId != _selectedRouteId) {
                      setState(() {
                        _selectedRouteId = newId;
                        final newRoute = routes.firstWhere((r) => r.id == newId);
                        final newStops = newRoute.sortedStops;
                        if (newStops.isNotEmpty) {
                          _fromStopId = newStops.first.id;
                          _toStopId = newStops.length > 1 ? newStops.last.id : newStops.first.id;
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // From / To Card with Swap Button
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // From Stop
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.trip_origin, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'কোথা থেকে (From)' : 'From Stop',
                                style: GoogleFonts.googleSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _fromStopId,
                                  isExpanded: true,
                                  items: stops.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s.id,
                                      child: Text(
                                        s.getName(isBn),
                                        style: GoogleFonts.googleSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _fromStopId = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),

                    // Swap Button Row
                    Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            final temp = _fromStopId;
                            _fromStopId = _toStopId;
                            _toStopId = temp;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.swap_vert, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'দিক পরিবর্তন করুন' : 'Reverse Direction',
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),

                    // To Stop
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'কোথায় যাবেন (To)' : 'To Stop',
                                style: GoogleFonts.googleSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _toStopId,
                                  isExpanded: true,
                                  items: stops.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s.id,
                                      child: Text(
                                        s.getName(isBn),
                                        style: GoogleFonts.googleSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _toStopId = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Big Fare Result Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isBn ? 'নির্ধারিত বাস ভাড়া' : 'Estimated Standard Fare',
                    style: GoogleFonts.googleSans(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        fare != null ? '৳${fare.toStringAsFixed(0)}' : '—',
                        style: GoogleFonts.googleSans(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBn ? 'জনপ্রতি' : 'per person',
                        style: GoogleFonts.googleSans(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activeRoute.getTitle(isBn),
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Toggle Full Route Sequence View
            InkWell(
              onTap: () {
                setState(() {
                  _showFullTimeline = !_showFullTimeline;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.linear_scale,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isBn
                              ? 'সম্পূর্ণ রুট ও স্টপ তালিকা (${stops.length}টি স্টপ)'
                              : 'Full Route & Stops (${stops.length} stops)',
                          style: GoogleFonts.googleSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _showFullTimeline
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            if (_showFullTimeline) ...[
              const SizedBox(height: 16),
              _buildRouteTimeline(activeRoute, stops, isBn),
            ],

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // Route Timeline View with Segment Badges
  Widget _buildRouteTimeline(
    LocalRoute route,
    List<RouteStop> stops,
    bool isBn,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          final isFirst = index == 0;
          final isLast = index == stops.length - 1;

          double? segmentFare;
          if (!isLast) {
            final nextStop = stops[index + 1];
            segmentFare = route.calculateFare(stop.id, nextStop.id);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Dot & Line
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFirst
                          ? Colors.green
                          : (isLast ? Colors.red : AppColors.primary),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2.5,
                      height: 52,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Stop Name and Segment Fare
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.getName(isBn),
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              fontWeight: (isFirst || isLast)
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (segmentFare != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            isBn
                                ? 'পরবর্তী স্টপ: ৳${segmentFare.toStringAsFixed(0)}'
                                : 'Next: ৳${segmentFare.toStringAsFixed(0)}',
                            style: GoogleFonts.googleSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: LONG DISTANCE BUS & COUNTERS
  // ==========================================
  Widget _buildLongDistanceTab(bool isBn) {
    final destsAsync = ref.watch(travelDestinationsProvider);
    final opsAsync = ref.watch(busOperatorsProvider);
    final opRoutesAsync = ref.watch(operatorDestinationRoutesProvider);

    return destsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(
        child: Text(isBn ? 'গন্তব্য লোড করতে ব্যর্থ' : 'Failed to load destinations: $e'),
      ),
      data: (destinations) {
        if (destinations.isEmpty) {
          return Center(
            child: Text(isBn ? 'কোনো গন্তব্য পাওয়া যায়নি' : 'No destinations found'),
          );
        }

        // Filter destinations by search query
        final filteredDests = destinations.where((d) {
          if (_searchQuery.isEmpty) return true;
          return d.nameBn.toLowerCase().contains(_searchQuery) ||
              d.nameEn.toLowerCase().contains(_searchQuery) ||
              (d.division?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        final currentDestId = _selectedDestinationId ??
            (filteredDests.isNotEmpty ? filteredDests.first.id : destinations.first.id);

        return Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _destSearchController,
                decoration: InputDecoration(
                  hintText: isBn
                      ? 'গন্তব্য বা বিভাগ খুঁজুন (যেমন: ঢাকা, খুলনা)...'
                      : 'Search destination or division...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _destSearchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ),

            // Horizontal Destination Filter Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: filteredDests.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final dest = filteredDests[index];
                  final isSelected = dest.id == currentDestId;

                  return FilterChip(
                    label: Text(dest.getName(isBn)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDestinationId = dest.id;
                      });
                    },
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primary,
                    labelStyle: GoogleFonts.googleSans(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : const Color(0xFF334155),
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 16, color: Color(0xFFE2E8F0)),

            // Operators List for Selected Destination
            Expanded(
              child: opsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (allOperators) {
                  return opRoutesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (e, st) => Center(child: Text('Error: $e')),
                    data: (allRoutes) {
                      // Find currently selected destination
                      final currentDest = destinations.firstWhere(
                        (d) => d.id == currentDestId,
                        orElse: () => TravelDestination(
                          id: currentDestId,
                          nameBn: '',
                          nameEn: '',
                          normalizedName: '',
                        ),
                      );
                      final destNameBn = currentDest.nameBn.trim().toLowerCase();
                      final destNameEn = currentDest.nameEn.trim().toLowerCase();

                      // Filter operators that serve this destination
                      final matchedList = <({BusOperator operator, OperatorDestinationRoute route})>[];

                      for (final op in allOperators) {
                        // 1. Direct route match in travel_operator_destinations
                        final matchedRoute = allRoutes.where(
                          (r) => r.destinationId == currentDestId && r.operatorId == op.id,
                        ).firstOrNull;

                        // 2. destinationIds list stored on operator in Firestore
                        final inOpDests = op.destinationIds.any((d) {
                          final clean = d.trim().toLowerCase();
                          return clean == currentDestId.toLowerCase() ||
                              clean == destNameBn ||
                              clean == destNameEn ||
                              (destNameBn.isNotEmpty && destNameBn.contains(clean)) ||
                              (clean.isNotEmpty && clean.contains(destNameBn));
                        });

                        // 3. Fallback: if operator has no destinationIds specified, show for all
                        final isGeneric = op.destinationIds.isEmpty;

                        if (matchedRoute != null || inOpDests || isGeneric) {
                          final effectiveRoute = matchedRoute ??
                              OperatorDestinationRoute(
                                id: 'route-${op.id}-$currentDestId',
                                operatorId: op.id,
                                destinationId: currentDestId,
                                serviceStatus: op.serviceStatus ?? 'নিয়মিত চলাচল (Regular)',
                                startingCounterName: op.startingPoint ??
                                    (op.counters.isNotEmpty ? op.counters.first.name : null),
                              );
                          matchedList.add((operator: op, route: effectiveRoute));
                        }
                      }

                      if (matchedList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_bus_filled_outlined,
                                    size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  isBn
                                      ? 'এই গন্তব্যে সরাসরি বাসের তথ্য এখনো যুক্ত করা হয়নি।'
                                      : 'No direct bus operator listed for this destination yet.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.googleSans(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: matchedList.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = matchedList[index];
                          return _buildOperatorCard(
                            operator: item.operator,
                            route: item.route,
                            destinationName: currentDest.getName(isBn),
                            isBn: isBn,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Redesigned Operator Card (Minimal, Zero-Overflow, Navigates to Details)
  Widget _buildOperatorCard({
    required BusOperator operator,
    required OperatorDestinationRoute route,
    required String destinationName,
    required bool isBn,
  }) {
    final statusText = route.serviceStatus.isNotEmpty
        ? route.serviceStatus
        : (operator.serviceStatus?.isNotEmpty == true ? operator.serviceStatus! : 'নিয়মিত চলাচল (Regular)');
    final startingStation = route.startingCounterName?.isNotEmpty == true
        ? route.startingCounterName!
        : (operator.startingPoint?.isNotEmpty == true ? operator.startingPoint! : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusOperatorDetailsScreen(
                operator: operator,
                destinationName: destinationName,
                serviceStatus: statusText,
                startingCounterName: startingStation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 1. Operator Header with Logo, Badges & Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOperatorLogo(operator),
                    const SizedBox(width: 12),

                    // Operator Name & English Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            operator.getName(isBn),
                            style: GoogleFonts.googleSans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (operator.nameEn.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              operator.nameEn,
                              style: GoogleFonts.googleSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Service Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusText,
                            style: GoogleFonts.googleSans(
                              color: const Color(0xFF1E5638),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags: Route + Bus Type + Starting Point
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Route Direction Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 15, color: Color(0xFF475569)),
                          const SizedBox(width: 5),
                          Text(
                            destinationName.isNotEmpty
                                ? (isBn ? 'কুষ্টিয়া ⇄ $destinationName' : 'Kushtia ⇄ $destinationName')
                                : (isBn ? 'কুষ্টিয়া ⇄ আন্তঃজেলা' : 'Kushtia ⇄ Intercity'),
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bus Type Pill
                    if (operator.busType != null && operator.busType!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.airline_seat_recline_extra_rounded, size: 14, color: Color(0xFF0284C7)),
                            const SizedBox(width: 5),
                            Text(
                              operator.busType!,
                              style: GoogleFonts.googleSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Kushtia Starting Point Pill
                    if (startingStation != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_rounded, size: 14, color: Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'বোর্ডিং: $startingStation' : 'Boarding: $startingStation',
                              style: GoogleFonts.googleSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Description or Note
                if (operator.descriptionBn != null && operator.descriptionBn!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    operator.descriptionBn!,
                    style: GoogleFonts.googleSans(
                      fontSize: 12.5,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],

                // Central Helpline
                if (operator.contactPrimary != null && operator.contactPrimary!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _makePhoneCall(operator.contactPrimary!),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_in_talk_rounded, size: 14, color: Color(0xFF1E5638)),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'হেল্পলাইন: ' : 'Helpline: ',
                          style: GoogleFonts.googleSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          operator.contactPrimary!,
                          style: GoogleFonts.googleSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E5638),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Bottom Action Bar: Counters Count & Open Dedicated Screen Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded, size: 15, color: Color(0xFF1E5638)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'কাউন্টার: ${operator.counters.length}টি'
                        : 'Counters: ${operator.counters.length}',
                    style: GoogleFonts.googleSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (operator.websiteUrl != null && operator.websiteUrl!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 12, color: Color(0xFF15803D)),
                        const SizedBox(width: 3),
                        Text(
                          isBn ? 'ই-টিকিট' : 'E-Ticket',
                          style: GoogleFonts.googleSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusOperatorDetailsScreen(
                          operator: operator,
                          destinationName: destinationName,
                          serviceStatus: statusText,
                          startingCounterName: startingStation,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: Text(
                    isBn ? 'কাউন্টার ও বিস্তারিত' : 'View Counters',
                    style: GoogleFonts.googleSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5638),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
}
