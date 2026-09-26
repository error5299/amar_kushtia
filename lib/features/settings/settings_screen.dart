import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations.dart';
import '../../services/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/google_logo.dart';
import '../auth/google_login_screen.dart';
import '../map/district_atlas_screen.dart';
import '../admin/admin_travel_guide_screen.dart';
import '../admin/admin_notification_sender_screen.dart';
import '../admin/admin_places_map_screen.dart';
import '../admin/admin_master_records_screen.dart';
import '../admin/admin_train_schedule_screen.dart';
import '../admin/admin_hub_screen.dart';
import '../admin/admin_notice_screen.dart';
import '../../models/app_update_info.dart';
import '../../services/notification_service.dart';
import '../../services/update_service.dart';
import '../../widgets/common/app_update_dialog.dart';
import '../../theme/app_typography.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _locationEnabled = false;
  bool _bgSyncEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (mounted) {
        setState(() {
          _locationEnabled = (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse);
        });
      }
    } catch (_) {}
  }

  Future<void> _handleLocationToggle(bool value) async {
    if (value) {
      final permission = await Geolocator.requestPermission();
      if (mounted) {
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          setState(() => _locationEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'লোকেশন পারমিশন সফলভাবে অনুমোদিত হয়েছে।',
                style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0B5233),
            ),
          );
        } else {
          setState(() => _locationEnabled = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ডিভাইস থেকে লোকেশন পারমিশন দেওয়া হয়নি।',
                style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    } else {
      setState(() => _locationEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 16),
              child: Text(
                isBn ? 'সেটিংস' : 'Settings',
                style: GoogleFonts.googleSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B5233),
                ),
              ),
            ),

            // Profile / Login Card (Dynamic based on real Firebase Auth state)
            _buildProfileOrLoginCard(context, authUser, isBn),

            const SizedBox(height: 20),

            // Section: পছন্দ (Preferences)
            _buildSectionHeader(isBn ? 'পছন্দ' : 'PREFERENCES'),
            _buildGroupedCard([
              _buildSettingTile(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFFEAF5EE),
                iconColor: const Color(0xFF0B5233),
                title: isBn ? 'ভাষা' : 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBn ? 'বাংলা' : 'English',
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  ],
                ),
                onTap: () => _showLanguageModal(context, ref, isBn),
              ),
            ]),

            const SizedBox(height: 20),

            // Section: অনুমতি (Permissions)
            _buildSectionHeader(isBn ? 'অনুমতি' : 'PERMISSIONS'),
            _buildGroupedCard([
              _buildSettingTile(
                icon: Icons.location_on_outlined,
                iconBg: const Color(0xFFEAF5EE),
                iconColor: const Color(0xFF0B5233),
                title: isBn ? 'লোকেশন' : 'Location',
                subtitle: isBn
                    ? 'শুধু কাছাকাছি সেবা পরিমাপ করার সময় ব্যবহার হয়'
                    : 'Used to measure nearby services and distances',
                trailing: CupertinoSwitch(
                  value: _locationEnabled,
                  activeTrackColor: const Color(0xFF0B5233),
                  onChanged: _handleLocationToggle,
                ),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.notifications_none_rounded,
                iconBg: const Color(0xFFE3EDF7),
                iconColor: const Color(0xFF2B6CB0),
                title: isBn ? 'নোটিফিকেশন' : 'Notification',
                subtitle: isBn
                    ? 'জরুরি সেবা ও গুরুত্বপূর্ণ তথ্যের আপডেট দেখাবে'
                    : 'Shows emergency services & live updates',
                trailing: Consumer(
                  builder: (context, ref, child) {
                    final isEnabled = ref.watch(notificationPermissionProvider);

                    return CupertinoSwitch(
                      value: isEnabled,
                      activeTrackColor: const Color(0xFF0B5233),
                      onChanged: (val) async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref
                            .read(notificationPermissionProvider.notifier)
                            .setEnabled(val);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? (isBn
                                      ? 'নোটিফিকেশন অনুমতি সক্রিয় করা হয়েছে।'
                                      : 'Notifications enabled.')
                                  : (isBn
                                      ? 'নোটিফিকেশন বন্ধ করা হয়েছে।'
                                      : 'Notifications disabled.'),
                              style: GoogleFonts.googleSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFF0B5233),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.sync_rounded,
                iconBg: const Color(0xFFEAF5EE),
                iconColor: const Color(0xFF0B5233),
                title: isBn ? 'ব্যাকগ্রাউন্ড সিঙ্ক' : 'Background Sync',
                subtitle: isBn
                    ? 'ইন্টারনেট সংযোগে লাইভ তথ্য স্বয়ংক্রিয় সিঙ্ক করবে'
                    : 'Syncs cloud records automatically when online',
                trailing: CupertinoSwitch(
                  value: _bgSyncEnabled,
                  activeTrackColor: const Color(0xFF0B5233),
                  onChanged: (val) {
                    setState(() => _bgSyncEnabled = val);
                  },
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Section: সহায়তা (Support)
            _buildSectionHeader(isBn ? 'সহায়তা' : 'SUPPORT'),
            _buildGroupedCard([
              _buildSettingTile(
                icon: Icons.star_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: isBn ? 'Amar Kushtia-কে রেটিং দিন' : 'Rate Amar Kushtia',
                subtitle: isBn ? 'দুই ট্যাপেই সবার উপকার' : 'Rate us on Play Store',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBn ? 'ধন্যবাদ! আপনার রেটিং রেকর্ড করা হয়েছে।' : 'Thank you for your rating!',
                        style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF0B5233),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.share_outlined,
                iconBg: const Color(0xFFEAF5EE),
                iconColor: const Color(0xFF0B5233),
                title: isBn ? 'অ্যাপটি শেয়ার করুন' : 'Share the App',
                subtitle: isBn ? 'বন্ধুকে প্রয়োজনীয় সেবা পেতে সাহায্য করুন' : 'Help others find services easily',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBn ? 'অ্যাপের লিংক ক্লিপবোর্ডে কপি করা হয়েছে।' : 'App link copied to clipboard.',
                        style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF0B5233),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.mail_outline_rounded,
                iconBg: const Color(0xFFE3EDF7),
                iconColor: const Color(0xFF2B6CB0),
                title: isBn ? 'মতামত পাঠান' : 'Send Feedback',
                subtitle: isBn ? 'সমস্যা জানান বা পরামর্শ দিন' : 'Report an issue or give feedback',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () => _showFeedbackDialog(context, isBn),
              ),
            ]),

            const SizedBox(height: 20),

            // Section: অ্যাপ সম্পর্কে (About App)
            _buildSectionHeader(isBn ? 'অ্যাপ সম্পর্কে' : 'ABOUT APP'),
            _buildGroupedCard([
              _buildSettingTile(
                icon: Icons.info_outline_rounded,
                iconBg: const Color(0xFFEAF5EE),
                iconColor: const Color(0xFF0B5233),
                title: isBn ? 'Amar Kushtia সম্পর্কে' : 'About Amar Kushtia',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () => _showAboutModal(context, isBn),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.map_outlined,
                iconBg: const Color(0xFFE3EDF7),
                iconColor: const Color(0xFF2B6CB0),
                title: isBn ? 'জেলা অ্যাটলাস ও পরিসংখ্যান' : 'District Atlas & Stats',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DistrictAtlasScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.lock_outline_rounded,
                iconBg: const Color(0xFFF0F2F1),
                iconColor: const Color(0xFF4B5563),
                title: isBn ? 'প্রাইভেসি পলিসি' : 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                onTap: () => _showPrivacyPolicyModal(context, isBn),
              ),
              _buildDivider(),
              Consumer(
                builder: (context, ref, child) {
                  final updateAsync = ref.watch(appUpdateInfoProvider);
                  final updateInfo = updateAsync.valueOrNull;
                  final hasUpdate = UpdateService.instance.isUpdateAvailable(updateInfo);

                  return Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.system_update_rounded,
                        iconBg: hasUpdate ? const Color(0xFFFEF3C7) : const Color(0xFFEAF5EE),
                        iconColor: hasUpdate ? const Color(0xFFD97706) : const Color(0xFF0B5233),
                        title: isBn ? 'সফটওয়্যার আপডেট' : 'Software Update',
                        subtitle: hasUpdate
                            ? (isBn ? 'নতুন সংস্করণ উপলব্ধ (${updateInfo!.latestVersion})' : 'New version available (${updateInfo!.latestVersion})')
                            : (isBn ? 'অ্যাপটি সর্বশেষ সংস্করণে আপডেট রয়েছে' : 'App is up to date'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasUpdate)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isBn ? 'নতুন' : 'NEW',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                          ],
                        ),
                        onTap: () => _showUpdateDialog(context, isBn, updateInfo, hasUpdate),
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.tag_rounded,
                        iconBg: const Color(0xFFF0F2F1),
                        iconColor: const Color(0xFF4B5563),
                        title: isBn ? 'বর্তমান ভার্সন' : 'Current Version',
                        subtitle: isBn ? 'বেটা রিলিজ ১ (অটো-সিঙ্ক)' : 'Beta Release 1 (Auto-sync)',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0B5233).withAlpha(40)),
                          ),
                          child: Text(
                            isBn ? AppVersion.formattedVersionBn : AppVersion.formattedVersionEn,
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontSize: 12.5,
                              color: Color(0xFF0B5233),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Section: অ্যাকাউন্ট (Account)
            _buildSectionHeader(isBn ? 'অ্যাকাউন্ট' : 'ACCOUNT'),
            _buildGroupedCard([
              if (authUser != null) ...[
                _buildSettingTile(
                  icon: Icons.logout_rounded,
                  iconBg: const Color(0xFFF0F2F1),
                  iconColor: const Color(0xFF4B5563),
                  title: isBn ? 'সাইন আউট' : 'Sign Out',
                  subtitle: isBn ? 'এই ফোন থেকে আপনার সেশন লগ আউট হবে' : 'Your session will be logged out',
                  onTap: () => _showSignOutDialog(context, isBn),
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.delete_outline_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFDC2626),
                  title: isBn ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
                  titleColor: const Color(0xFFDC2626),
                  subtitle: isBn
                      ? 'আপনার অ্যাকাউন্ট ও তথ্য স্থায়ীভাবে মুছে যাবে'
                      : 'Permanently deletes your account & data',
                  onTap: () => _showDeleteAccountDialog(context, isBn),
                ),
              ] else ...[
                _buildSettingTile(
                  icon: Icons.login_rounded,
                  iconBg: const Color(0xFFEAF5EE),
                  iconColor: const Color(0xFF0B5233),
                  title: isBn ? 'লগইন করুন' : 'Sign In',
                  subtitle: isBn
                      ? 'অ্যাকাউন্টে প্রবেশ করুন বা নতুন অ্যাকাউন্ট খুলুন'
                      : 'Sign in or create an account',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoogleLoginScreen()),
                    );
                  },
                ),
              ],
            ]),

            // Section: অ্যাডমিন প্যানেল (Admin CMS) - Only visible to authenticated Admins
            if (isAdmin) ...[
              const SizedBox(height: 20),
              _buildSectionHeader(isBn ? 'অ্যাডমিন প্যানেল' : 'ADMIN PANEL'),
              _buildGroupedCard([
                _buildSettingTile(
                  icon: Icons.dashboard_rounded,
                  iconBg: const Color(0xFF071F14),
                  iconColor: const Color(0xFF34D399),
                  title: isBn ? 'সুপার অ্যাডমিন ড্যাশবোর্ড' : 'Admin Control Center',
                  subtitle: isBn
                      ? 'সকল ফিচার, স্থান, বাস, ট্রেন ও নোটিশ এক স্ক্রিন থেকে পরিচালনা'
                      : 'All-in-one control center for all app features',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminHubScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.edit_note_rounded,
                  iconBg: const Color(0xFFF0FDF4),
                  iconColor: const Color(0xFF059669),
                  title: isBn ? 'সকল স্থান ও সেবার তথ্য পরিচালনা' : 'Places & Services CMS',
                  subtitle: isBn
                      ? 'সকল স্থান, হাসপাতাল, ডাক্তার ও সেবার তথ্য যুক্ত, এডিট ও ডিলিট'
                      : 'Add, edit, or delete all places, hospitals & services',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminMasterRecordsScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.directions_bus_rounded,
                  iconBg: const Color(0xFFEAF5EE),
                  iconColor: const Color(0xFF0B5233),
                  title: isBn ? 'ভ্রমণ গাইড ব্যবস্থাপনা' : 'Travel Guide CMS',
                  subtitle: isBn
                      ? 'বাস রুট, স্টপ, ভাড়া ও দূরপাল্লার কাউন্টার পরিচালনা'
                      : 'Manage bus routes, stops, fares & counters',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminTravelGuideScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.train_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  title: isBn ? 'ট্রেন সময়সূচি ব্যবস্থাপনা' : 'Train Schedule CMS',
                  subtitle: isBn
                      ? 'টাইম টেবিল নং-৫৪ অনুসারে পশ্চিমাঞ্চলের ট্রেনের সময়সূচি এডিট'
                      : 'Manage Western Railway train timetable & timings',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminTrainScheduleScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.campaign_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  title: isBn ? 'হোম স্ক্রিন নোটিশ ও হটলাইন' : 'Notice Banner & Hotlines',
                  subtitle: isBn
                      ? 'অ্যাপের শীর্ষে ব্যানার ঘোষণা ও ৯৯৯ হটলাইন পরিচালনা'
                      : 'Manage home announcement banner & hotlines',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminNoticeScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.map_rounded,
                  iconBg: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  title: isBn ? 'গুগল ম্যাপস লোকেশন লিংক' : 'Google Maps Location Links',
                  subtitle: isBn
                      ? 'সকল স্থান, দর্শনীয় স্থান ও সেবার গুগল ম্যাপস লোকেশন লিংক'
                      : 'Configure Google Maps links for places & services',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPlacesMapScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.notifications_active_rounded,
                  iconBg: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF7C3AED),
                  title: isBn ? 'পুশ নোটিফিকেশন পাঠান' : 'Send Push Notification',
                  subtitle: isBn
                      ? 'সকল ব্যবহারকারীকে জরুরি বার্তা বা নোটিশ পাঠান'
                      : 'Broadcast alerts or notices to all users',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminNotificationSenderScreen()),
                    );
                  },
                ),
              ]),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Profile Card (When logged in) or Login Card (When guest)
  Widget _buildProfileOrLoginCard(BuildContext context, dynamic user, bool isBn) {
    if (user != null) {
      final name = (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : 'Google ব্যবহারকারী';
      final email = user.email ?? 'Google অ্যাকাউন্ট';
      final photoUrl = user.photoURL as String?;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B5233).withAlpha(40), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEAF5EE),
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                        name[0].toUpperCase(),
                        style: GoogleFonts.googleSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B5233),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.googleSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.googleSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GoogleLogo(size: 13),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'Google অ্যাকাউন্ট' : 'Google Account',
                          style: GoogleFonts.googleSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Guest / Not Logged In Profile Card
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GoogleLoginScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0B5233).withAlpha(30), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: GoogleLogo(size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'Google দিয়ে লগইন করুন' : 'Sign in with Google',
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    isBn
                        ? 'ব্যক্তিগত তথ্য ও সেবা সংরক্ষণ করতে প্রবেশ করুন'
                        : 'Sign in to save personal settings and data',
                    style: GoogleFonts.googleSans(
                      fontSize: 12.5,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B5233),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isBn ? 'লগইন' : 'Login',
                style: GoogleFonts.googleSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.googleSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.googleSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF1F2937),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.googleSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.7,
      indent: 68,
      color: Color(0xFFF1F3F2),
    );
  }

  void _showLanguageModal(BuildContext context, WidgetRef ref, bool isBn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'ভাষা নির্বাচন করুন' : 'Select Language',
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇧🇩', style: TextStyle(fontSize: 24)),
                  title: Text(
                    'বাংলা (Bengali)',
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: isBn ? FontWeight.w700 : FontWeight.w500,
                      color: isBn ? const Color(0xFF0B5233) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: isBn
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B5233))
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('bn'));
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: Text(
                    'English',
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: !isBn ? FontWeight.w700 : FontWeight.w500,
                      color: !isBn ? const Color(0xFF0B5233) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: !isBn
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B5233))
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutModal(BuildContext context, bool isBn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'Amar Kushtia সম্পর্কে' : 'About Amar Kushtia',
                  style: GoogleFonts.googleSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B5233),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isBn
                      ? 'Amar Kushtia কুষ্টিয়া জেলার সকল নাগরিক সেবা, হাসপাতাল ও স্বাস্থ্যসেবা, জরুরি যোগাযোগ (পুলিশ, ফায়ার সার্ভিস), পর্যটন কেন্দ্র, ট্রেন সূচি এবং উপজেলা তথ্য সম্বলিত একটি সমন্বিত ডিজিটাল ডিরেক্টরি প্ল্যাটফর্ম।'
                      : 'Amar Kushtia is an integrated digital civic directory for Kushtia District, providing comprehensive citizen services, hospital beds and surgeries, emergency hotlines, tourism guides, train schedules, and verified contact points.',
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF0B5233), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'মাস্টার ডাটা সংস্করণ ২.০ দ্বারা পরিচালিত'
                              : 'Powered by Master Data Document v2.0',
                          style: GoogleFonts.googleSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B5233),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyModal(BuildContext context, bool isBn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'প্রাইভেসি পলিসি' : 'Privacy Policy',
                  style: GoogleFonts.googleSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B5233),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isBn
                      ? '১. গোপনীয়তা রক্ষা:\nআপনার ব্যক্তিগত তথ্য কোনো বাণিজ্যিক তৃতীয় পক্ষের কাছে বিক্রি বা শেয়ার করা হয় না।\n\n২. লোকেশন তথ্য:\nকাছের সেবা ও দূরত্ব পরিমাপের জন্য ডিভাইস লোকেশন ব্যবহার করা হয়। লোকেশন সার্ভারে সংরক্ষণ করা হয় না।\n\n৩. ডেটা নিরাপত্তা:\nফায়ারবেস সিকিউরিটি রুলস দ্বারা সমস্ত ডেটা সুরক্ষিত এবং এনক্রিপ্ট করা।'
                      : '1. Privacy Protection: Your personal info is never sold.\n2. Location: Device location is solely used for nearby service calculation.\n3. Security: Encrypted via Google Firebase.',
                  style: GoogleFonts.googleSans(
                    fontSize: 13.5,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isBn) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isBn ? 'মতামত বা পরামর্শ পাঠান' : 'Send Feedback',
            style: GoogleFonts.googleSans(fontWeight: FontWeight.w700, color: const Color(0xFF0B5233)),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: GoogleFonts.googleSans(fontSize: 14, color: const Color(0xFF1F2937), fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: isBn ? 'আপনার মন্তব্য বা পরামর্শ লিখুন...' : 'Write your suggestions...',
              hintStyle: GoogleFonts.googleSans(fontSize: 14, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
              filled: true,
              fillColor: const Color(0xFFF4F6F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isBn ? 'বাতিল' : 'Cancel',
                style: GoogleFonts.googleSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5233),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBn ? 'আপনার মতামতের জন্য ধন্যবাদ!' : 'Thank you for your feedback!',
                      style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF0B5233),
                  ),
                );
              },
              child: Text(
                isBn ? 'পাঠান' : 'Send',
                style: GoogleFonts.googleSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isBn ? 'সাইন আউট নিশ্চিত করুন' : 'Confirm Sign Out',
            style: GoogleFonts.googleSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            isBn
                ? 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট থেকে সাইন আউট করতে চান?'
                : 'Are you sure you want to sign out?',
            style: GoogleFonts.googleSans(fontSize: 14, color: const Color(0xFF4B5563), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isBn ? 'না' : 'Cancel',
                style: GoogleFonts.googleSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5233),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await AuthService.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBn ? 'সফলভাবে সাইন আউট করা হয়েছে।' : 'Successfully signed out.',
                        style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF0B5233),
                    ),
                  );
                }
              },
              child: Text(
                isBn ? 'হ্যাঁ, সাইন আউট' : 'Yes, Sign Out',
                style: GoogleFonts.googleSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isBn ? 'অ্যাকাউন্ট মুছে ফেলা' : 'Delete Account',
            style: GoogleFonts.googleSans(fontWeight: FontWeight.w700, color: const Color(0xFFDC2626)),
          ),
          content: Text(
            isBn
                ? 'সতর্কতা: অ্যাকাউন্ট মুছে ফেললে আপনার সকল সংরক্ষিত তথ্য স্থায়ীভাবে বিলুপ্ত হবে।'
                : 'Warning: This action will permanently delete all your data.',
            style: GoogleFonts.googleSans(fontSize: 14, color: const Color(0xFF4B5563), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isBn ? 'বাতিল' : 'Cancel',
                style: GoogleFonts.googleSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await AuthService.instance.deleteAccount();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBn ? 'অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলা হয়েছে।' : 'Account permanently deleted.',
                          style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBn ? 'ত্রুটি ঘটেছে: পুনরায় লগইন করে চেষ্টা করুন।' : 'Error deleting account.',
                          style: GoogleFonts.googleSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  }
                }
              },
              child: Text(
                isBn ? 'মুছে ফেলুন' : 'Delete',
                style: GoogleFonts.googleSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, bool isBn, AppUpdateInfo? updateInfo, bool hasUpdate) {
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasUpdate ? const Color(0xFFFEF3C7) : const Color(0xFFEAF5EE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasUpdate ? Icons.system_update_rounded : Icons.verified_rounded,
                      color: hasUpdate ? const Color(0xFFD97706) : const Color(0xFF0B5233),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasUpdate
                              ? (isBn ? 'নতুন আপডেট প্রস্তুত!' : 'New Update Available!')
                              : (isBn ? 'আপনার অ্যাপটি আপ-টু-ডেট' : 'Your App is Up to Date'),
                          style: const TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          isBn
                              ? 'বর্তমান সংস্করণ: ${AppVersion.formattedVersionBn}'
                              : 'Current version: ${AppVersion.formattedVersionEn}',
                          style: TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasUpdate && updateInfo != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'ভার্সন: v${updateInfo.latestVersion}' : 'Version: v${updateInfo.latestVersion}',
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: Color(0xFF0B5233),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              updateInfo.channel.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (updateInfo.getTitle(isBn).isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          updateInfo.getTitle(isBn),
                          style: const TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                      if (updateInfo.getNotes(isBn).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'নতুন পরিবর্তনসমূহ:' : 'What\'s new:',
                          style: const TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          updateInfo.getNotes(isBn),
                          style: TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.45,
                          ),
                        ),
                      ],
                      if (updateInfo.isForceUpdate) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Color(0xFFDC2626)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isBn
                                      ? 'এই আপডেটটি অ্যাপ ব্যবহারের জন্য বাধ্যতামূলক।'
                                      : 'This update is mandatory to continue using the app.',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.primaryFont,
                                    fontSize: 11.5,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showAppUpdatePopupDialog(
                      context: context,
                      isBn: isBn,
                      updateInfo: updateInfo,
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                  label: Text(
                    isBn ? 'এখনই আপডেট ও ইনস্টল করুন' : 'Update & Install Now',
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFont,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5233),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'আপনার কাছে আমাদের সর্বশেষ রিলিজ ইনস্টল করা আছে (${AppVersion.formattedVersionBn})।'
                              : 'You have the latest version installed (${AppVersion.formattedVersionEn}).',
                          style: const TextStyle(
                            fontFamily: AppTypography.primaryFont,
                            fontSize: 13,
                            color: Color(0xFF14532D),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBn ? 'আপডেট যাচাই করা হচ্ছে...' : 'Checking for updates...',
                          style: const TextStyle(fontFamily: AppTypography.primaryFont),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    final latest = await UpdateService.instance.fetchLatestUpdate();
                    if (!context.mounted) return;
                    final hasNew = UpdateService.instance.isUpdateAvailable(latest);
                    _showUpdateDialog(context, isBn, latest, hasNew);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0B5233), size: 20),
                  label: Text(
                    isBn ? 'পুনরায় চেক করুন' : 'Check Again',
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFont,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B5233),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0B5233), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
