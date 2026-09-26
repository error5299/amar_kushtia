import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import 'admin_master_records_screen.dart';
import 'admin_travel_guide_screen.dart';
import 'admin_train_schedule_screen.dart';
import 'admin_notice_screen.dart';
import 'admin_places_map_screen.dart';
import 'admin_notification_sender_screen.dart';

/// Central Executive Admin Hub Screen:
/// Gives full access to manage and update EVERY feature in the Amar Kushtia app.
class AdminHubScreen extends ConsumerWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(isBn ? 'সংরক্ষিত' : 'Restricted')),
        body: Center(
          child: Text(
            isBn ? 'শুধুমাত্র অনুমোদিত অ্যাডমিনদের জন্য সংরক্ষিত।' : 'Restricted to Administrators only.',
            style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final busOpsAsync = ref.watch(busOperatorsProvider);
    final trainsAsync = ref.watch(trainSchedulesProvider);

    final recordsCount = recordsAsync.valueOrNull?.length ?? 80;
    final busOpsCount = busOpsAsync.valueOrNull?.length ?? 6;
    final trainsCount = trainsAsync.valueOrNull?.length ?? 18;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: Text(
          isBn ? 'সুপার অ্যাডমিন ড্যাশবোর্ড' : 'Admin Control Center',
          style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF071F14), Color(0xFF0B5233), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x200B5233),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'সুপার অ্যাডমিন মোড সক্রিয়' : 'Admin Mode Active',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.cloud_done_rounded, color: Color(0xFF34D399), size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBn ? 'আমার কুষ্টিয়া — অল-ইন-ওয়ান সিএমএস' : 'Amar Kushtia All-in-One CMS',
                    style: GoogleFonts.googleSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn
                        ? 'অ্যাপের যেকোনো স্থান, সেবা, ডাক্তার, বাস কাউন্টার, ট্রেন শিডিউল ও জরুরি নোটিশ সরাসরি আপডেট করুন।'
                        : 'Manage every place, hospital, train, bus counter, and announcement live across the app.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFD1FAE5), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Quick stats pill row
                  Row(
                    children: [
                      _buildQuickStat(isBn ? 'মোট স্থান ও সেবা' : 'Total Places', '$recordsCount+'),
                      const SizedBox(width: 8),
                      _buildQuickStat(isBn ? 'বাস সার্ভিস' : 'Bus Operators', '$busOpsCount'),
                      const SizedBox(width: 8),
                      _buildQuickStat(isBn ? 'ট্রেন শিডিউল' : 'Trains', '$trainsCount'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              isBn ? 'অ্যাপ ফিচার পরিচালনা মডিউল' : 'App Management Modules',
              style: GoogleFonts.googleSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Modules Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
              children: [
                _buildModuleCard(
                  context,
                  title: isBn ? 'সকল স্থান ও সেবা' : 'Places & Services',
                  subtitle: isBn ? 'হাসপাতাল, ডাক্তার, দর্শনীয় স্থান' : 'Hospitals, doctors, spots',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF059669),
                  count: '$recordsCount টি',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMasterRecordsScreen())),
                ),
                _buildModuleCard(
                  context,
                  title: isBn ? 'বাস ও ভ্রমণ গাইড' : 'Travel Guide CMS',
                  subtitle: isBn ? 'বাস রুট, কাউন্টার ও ভাড়া' : 'Bus routes, counters & fares',
                  icon: Icons.directions_bus_rounded,
                  color: const Color(0xFF0D9488),
                  count: '$busOpsCount টি অপারেটর',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTravelGuideScreen())),
                ),
                _buildModuleCard(
                  context,
                  title: isBn ? 'ট্রেন সময়সূচি' : 'Train Timetables',
                  subtitle: isBn ? 'টাইম টেবিল-৫৪ ট্রেন ও সময়' : 'Time table-54 train times',
                  icon: Icons.train_rounded,
                  color: const Color(0xFF2563EB),
                  count: '$trainsCount টি ট্রেন',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTrainScheduleScreen())),
                ),
                _buildModuleCard(
                  context,
                  title: isBn ? 'ব্যানার নোটিশ ও হটলাইন' : 'Notice & Hotlines',
                  subtitle: isBn ? 'হোম স্ক্রিন ঘোষণা ও ৯৯৯' : 'Home banner & 999 hotlines',
                  icon: Icons.campaign_rounded,
                  color: const Color(0xFFD97706),
                  count: isBn ? 'সক্রিয়' : 'Active',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNoticeScreen())),
                ),
                _buildModuleCard(
                  context,
                  title: isBn ? 'ম্যাপস লোকেশন লিংক' : 'Maps Location Links',
                  subtitle: isBn ? 'গুগল ম্যাপস ও কোঅর্ডিনেট' : 'Google Maps URLs',
                  icon: Icons.map_rounded,
                  color: const Color(0xFF0284C7),
                  count: isBn ? 'কনফিগ' : 'Config',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPlacesMapScreen())),
                ),
                _buildModuleCard(
                  context,
                  title: isBn ? 'নোটিফিকেশন পাঠান' : 'Push Notifications',
                  subtitle: isBn ? 'ইউজারদের জরুরি সতর্কবার্তা' : 'Broadcast to all users',
                  icon: Icons.notifications_active_rounded,
                  color: const Color(0xFF7C3AED),
                  count: isBn ? 'ব্রডকাস্ট' : 'Broadcast',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationSenderScreen())),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.googleSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
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
}
