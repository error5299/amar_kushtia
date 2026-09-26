import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/travel_guide_models.dart';

class BusOperatorDetailsScreen extends StatefulWidget {
  final BusOperator operator;
  final String destinationName;
  final String? serviceStatus;
  final String? startingCounterName;

  const BusOperatorDetailsScreen({
    super.key,
    required this.operator,
    required this.destinationName,
    this.serviceStatus,
    this.startingCounterName,
  });

  @override
  State<BusOperatorDetailsScreen> createState() => _BusOperatorDetailsScreenState();
}

class _BusOperatorDetailsScreenState extends State<BusOperatorDetailsScreen> {
  String _counterSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _counterSearchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebUrl(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMapCoordinates(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMapUrl(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label নম্বর কপি করা হয়েছে'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getUpazilaName(String? upazilaId) {
    switch (upazilaId) {
      case 'UPZ-002':
      case 'kushtia_sadar':
        return 'কুষ্টিয়া সদর';
      case 'UPZ-003':
      case 'kumarkhali':
        return 'কুমারখালী';
      case 'UPZ-004':
      case 'bheramara':
        return 'ভেড়ামারা';
      case 'UPZ-005':
      case 'mirpur':
        return 'মিরপুর';
      case 'UPZ-006':
      case 'khoksa':
        return 'খোকসা';
      case 'UPZ-007':
      case 'daulatpur':
        return 'দৌলতপুর';
      default:
        return 'কুষ্টিয়া';
    }
  }

  Widget _buildOperatorAvatar() {
    final op = widget.operator;
    if (op.logoUrl != null && op.logoUrl!.trim().isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            op.logoUrl!.trim(),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildDefaultEmblem(),
          ),
        ),
      );
    }
    return _buildDefaultEmblem();
  }

  Widget _buildDefaultEmblem() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5638), Color(0xFF2E7D52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.operator;
    final status = widget.serviceStatus?.isNotEmpty == true
        ? widget.serviceStatus!
        : (op.serviceStatus?.isNotEmpty == true ? op.serviceStatus! : 'নিয়মিত চলাচল (Regular)');
    final boarding = widget.startingCounterName?.isNotEmpty == true
        ? widget.startingCounterName!
        : (op.startingPoint?.isNotEmpty == true ? op.startingPoint! : null);

    final filteredCounters = op.counters.where((c) {
      if (_counterSearchQuery.isEmpty) return true;
      final q = _counterSearchQuery;
      final upz = _getUpazilaName(c.upazilaId).toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.addressBn.toLowerCase().contains(q) ||
          c.phonePrimary.contains(q) ||
          (c.phoneSecondary?.contains(q) ?? false) ||
          upz.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          op.nameBn.isNotEmpty ? op.nameBn : op.nameEn,
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Operator Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + Name + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOperatorAvatar(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              op.nameBn,
                              style: GoogleFonts.googleSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            if (op.nameEn.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                op.nameEn,
                                style: GoogleFonts.googleSans(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              status,
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
                  const SizedBox(height: 14),

                  // Route & Bus Type Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Route Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_horiz_rounded, size: 15, color: Color(0xFF475569)),
                            const SizedBox(width: 5),
                            Text(
                              widget.destinationName.isNotEmpty
                                  ? 'কুষ্টিয়া ⇄ ${widget.destinationName}'
                                  : 'কুষ্টিয়া ⇄ দূরপাল্লার রুট',
                              style: GoogleFonts.googleSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bus Type Tag
                      if (op.busType != null && op.busType!.trim().isNotEmpty)
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
                                op.busType!.trim(),
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0369A1),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Kushtia Boarding Point Tag
                      if (boarding != null && boarding.isNotEmpty)
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
                                'বোর্ডিং: $boarding',
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Description / Notes
                  if (op.descriptionBn != null && op.descriptionBn!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      op.descriptionBn!,
                      style: GoogleFonts.googleSans(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Online Ticket Booking Card (If website URL is available)
            if (op.websiteUrl != null && op.websiteUrl!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'অনলাইন টিকিট বুকিং',
                            style: GoogleFonts.googleSans(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'অফিসিয়াল ওয়েবসাইট থেকে সরাসরি টিকিট কাটুন',
                            style: GoogleFonts.googleSans(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openWebUrl(op.websiteUrl!),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: Text(
                        'টিকিট বুকিং',
                        style: GoogleFonts.googleSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF064E3B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. Central Helpline Banner
            if (op.contactPrimary != null && op.contactPrimary!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Color(0xFF1E5638)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'কেন্দ্রীয় হেল্পলাইন নম্বর',
                            style: GoogleFonts.googleSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            op.contactPrimary!,
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _makePhoneCall(op.contactPrimary!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5638),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'কল করুন',
                        style: GoogleFonts.googleSans(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Ticket Counters Header & Search Filter
            Row(
              children: [
                const Icon(Icons.store_rounded, size: 20, color: Color(0xFF1E5638)),
                const SizedBox(width: 8),
                Text(
                  'কুষ্টিয়ার সকল টিকিট কাউন্টার (${op.counters.length}টি)',
                  style: GoogleFonts.googleSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search filter if multiple counters
            if (op.counters.length > 2) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'কাউন্টারের নাম, এলাকা বা ফোন নম্বর লিখুন...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF1E5638)),
                  suffixIcon: _counterSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              const SizedBox(height: 12),
            ],

            // 5. Counters List
            if (filteredCounters.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.store_outlined, size: 44, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      op.counters.isEmpty
                          ? 'এই অপারেটরের কাউন্টারসমূহ শীঘ্রই যুক্ত করা হবে।'
                          : 'কোনো কাউন্টার মেলেনি।',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.googleSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCounters.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final counter = filteredCounters[index];
                  final upzName = _getUpazilaName(counter.upazilaId);
                  final hasMap = (counter.mapUrl != null && counter.mapUrl!.isNotEmpty) ||
                      (counter.latitude != null && counter.longitude != null);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: counter.isStartingPoint ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                        width: counter.isStartingPoint ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Counter Name + Upazila Badge + Main Boarding Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                counter.name,
                                style: GoogleFonts.googleSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                upzName,
                                style: GoogleFonts.googleSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            if (counter.isStartingPoint) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Text(
                                  'মূল পয়েন্ট',
                                  style: GoogleFonts.googleSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Counter Address / Landmark
                        if (counter.addressBn.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFFD97706)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  counter.addressBn,
                                  style: GoogleFonts.googleSans(
                                    fontSize: 12.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Counter Phone Numbers
                        if (counter.phonePrimary.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF1E5638)),
                              const SizedBox(width: 5),
                              Text(
                                'ফোন: ${counter.phonePrimary}',
                                style: GoogleFonts.googleSans(
                                  fontSize: 13,
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (counter.phoneSecondary != null && counter.phoneSecondary!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '(${counter.phoneSecondary})',
                                  style: GoogleFonts.googleSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Action Buttons: Call, Map, Copy
                        Row(
                          children: [
                            // 1. Call Button
                            if (counter.phonePrimary.isNotEmpty)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _makePhoneCall(counter.phonePrimary),
                                  icon: const Icon(Icons.phone_forwarded_rounded, size: 15),
                                  label: Text(
                                    'কল করুন',
                                    style: GoogleFonts.googleSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E5638),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),

                            // 2. Google Map Navigation Button
                            if (hasMap)
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (counter.mapUrl != null && counter.mapUrl!.isNotEmpty) {
                                    _openMapUrl(counter.mapUrl!);
                                  } else if (counter.latitude != null && counter.longitude != null) {
                                    _openMapCoordinates(counter.latitude!, counter.longitude!);
                                  }
                                },
                                icon: const Icon(Icons.map_rounded, size: 15, color: Color(0xFF0284C7)),
                                label: Text(
                                  'ম্যাপ',
                                  style: GoogleFonts.googleSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                                  backgroundColor: const Color(0xFFF0F9FF),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                            if (counter.phonePrimary.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              // 3. Copy Phone Button
                              IconButton(
                                onPressed: () => _copyToClipboard(counter.phonePrimary, counter.name),
                                icon: const Icon(Icons.copy_rounded, size: 17, color: Color(0xFF64748B)),
                                tooltip: 'ফোন নম্বর কপি করুন',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
