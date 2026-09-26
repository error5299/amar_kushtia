import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/transport_tables.dart';
import '../../repositories/records_repository.dart';
import '../../widgets/templates/tpl03_schedule_table.dart';

/// Dedicated Railway Screen: Focuses 100% on Trains, Timetables,
/// Route Filtering & Real-time Live Tracking (Without any Bus elements).
class TransportScreen extends ConsumerStatefulWidget {
  const TransportScreen({super.key});

  @override
  ConsumerState<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends ConsumerState<TransportScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.hasClients && _scrollController.offset > 300;
      if (show != _showBackToTop) setState(() => _showBackToTop = show);
    });
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
    final trains = ref.watch(trainSchedulesProvider).valueOrNull ?? SeedMasterData.trainSchedules;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              tooltip: 'Back to top',
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'ট্রেন সময়সূচি (পশ্চিমাঞ্চল)' : 'Western Railway Timetable',
              style: GoogleFonts.googleSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              isBn ? 'টাইম টেবিল নং-৫৪ • ১০ মার্চ ২০২৫' : 'Time Table No-54 • 10 Mar 2025',
              style: GoogleFonts.googleSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          // Official Bangladesh Railway E-Ticket Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://eticket.railway.gov.bd');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5233),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.confirmation_num_rounded, size: 14),
              label: Text(
                isBn ? 'ই-টিকিট' : 'E-Ticket',
                style: GoogleFonts.googleSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Tpl03ScheduleTable(
        trains: trains,
        setting: TransportSetting(),
        scrollController: _scrollController,
      ),
    );
  }
}
