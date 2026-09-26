import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations.dart';
import '../../models/app_notification.dart';
import '../../services/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';


class AdminNotificationSenderScreen extends ConsumerStatefulWidget {
  const AdminNotificationSenderScreen({super.key});

  @override
  ConsumerState<AdminNotificationSenderScreen> createState() =>
      _AdminNotificationSenderScreenState();
}

class _AdminNotificationSenderScreenState
    extends ConsumerState<AdminNotificationSenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleBnController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _bodyBnController = TextEditingController();
  final _bodyEnController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  String _selectedRoute = 'none';
  bool _isSending = false;

  final Map<String, String> _routeOptions = {
    'none': 'কোনো নির্দিষ্ট লিংক নেই (None)',
    'travel_guide': 'ভ্রমণ গাইড (Travel Guide)',
    'emergency': 'জরুরি সেবা (Emergency)',
    'healthcare': 'স্বাস্থ্যসেবা (Healthcare)',
  };

  @override
  void dispose() {
    _titleBnController.dispose();
    _titleEnController.dispose();
    _bodyBnController.dispose();
    _bodyEnController.dispose();
    super.dispose();
  }

  Future<void> _handleBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      final titleBn = _titleBnController.text.trim();
      final titleEn = _titleEnController.text.trim().isNotEmpty
          ? _titleEnController.text.trim()
          : titleBn;
      final bodyBn = _bodyBnController.text.trim();
      final bodyEn = _bodyEnController.text.trim().isNotEmpty
          ? _bodyEnController.text.trim()
          : bodyBn;

      await NotificationService.sendNotification(
        titleBn: titleBn,
        titleEn: titleEn,
        bodyBn: bodyBn,
        bodyEn: bodyEn,
        type: _selectedType,
        targetRoute: _selectedRoute == 'none' ? null : _selectedRoute,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('নোটিফিকেশন সফলভাবে সকল ব্যবহারকারীর কাছে পাঠানো হয়েছে!'),
          backgroundColor: AppColors.primary,
        ),
      );

      nav.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('নোটিফিকেশন পাঠাতে ব্যর্থ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAF8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            isBn ? 'অ্যাডমিন এক্সেস' : 'Admin Access',
            style: GoogleFonts.googleSans(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_rounded, size: 64, color: Color(0xFFD97706)),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'শুধুমাত্র অ্যাডমিনদের জন্য সংরক্ষিত' : 'Restricted to Administrators',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'এই প্যানেল থেকে শুধুমাত্র অনুমোদিত অ্যাডমিনরা নোটিফিকেশন পাঠাতে পারেন।'
                      : 'Only authorized administrators can send broadcast push notifications.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isBn ? 'ব্রডকাস্ট নোটিফিকেশন পাঠান' : 'Broadcast Push Notification',
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBn
                            ? 'এখান থেকে পাঠানো নোটিফিকেশন সকল ব্যবহারকারী তাৎক্ষণিকভাবে তাদের ফোনে এবং ইনবক্সে পাবেন।'
                            : 'Notifications sent here will be received instantly by all users.',
                        style: GoogleFonts.googleSans(
                          fontSize: 12.5,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title (Bangla)
              Text(
                isBn ? 'নোটিফিকেশন শিরোনাম (বাংলা) *' : 'Title (Bangla) *',
                style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleBnController,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'শিরোনাম আবশ্যক' : null,
                decoration: InputDecoration(
                  hintText: isBn ? 'যেমন: ভেড়ামারা রুটে নতুন বাস চালু হয়েছে' : 'Enter Bangla title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title (English)
              Text(
                isBn ? 'নোটিফিকেশন শিরোনাম (ইংরেজি - ঐচ্ছিক)' : 'Title (English - Optional)',
                style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleEnController,
                decoration: InputDecoration(
                  hintText: 'e.g. New bus service started on Bheramara route',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Body (Bangla)
              Text(
                isBn ? 'বিস্তারিত বার্তা (বাংলা) *' : 'Message Body (Bangla) *',
                style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyBnController,
                maxLines: 3,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'বার্তা আবশ্যক' : null,
                decoration: InputDecoration(
                  hintText: isBn
                      ? 'নাগরিকদের প্রয়োজনীয় তথ্য বা জরুরি বার্তা এখানে লিখুন...'
                      : 'Enter message details...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Body (English)
              Text(
                isBn ? 'বিস্তারিত বার্তা (ইংরেজি - ঐচ্ছিক)' : 'Message Body (English - Optional)',
                style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyEnController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter English message details...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notification Category/Type
              Text(
                isBn ? 'ক্যাটাগরি বা ধরণ' : 'Category / Type',
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
                  child: DropdownButton<NotificationType>(
                    value: _selectedType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: NotificationType.general,
                        child: Text('সাধারণ নোটিশ (General)'),
                      ),
                      DropdownMenuItem(
                        value: NotificationType.emergency,
                        child: Text('জরুরি সতর্কতা (Emergency Alert)'),
                      ),
                      DropdownMenuItem(
                        value: NotificationType.contentUpdate,
                        child: Text('নতুন সেবা বা তথ্য (Content Update)'),
                      ),
                      DropdownMenuItem(
                        value: NotificationType.travel,
                        child: Text('ভ্রমণ ও বাস রুট (Travel Guide)'),
                      ),
                      DropdownMenuItem(
                        value: NotificationType.healthcare,
                        child: Text('স্বাস্থ্যসেবা (Healthcare)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Target Action Link
              Text(
                isBn ? 'ট্যাপ করলে কোন স্ক্রিনে যাবে?' : 'Target Screen on Tap',
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
                    value: _selectedRoute,
                    isExpanded: true,
                    items: _routeOptions.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRoute = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSending ? null : _handleBroadcast,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _isSending
                        ? (isBn ? 'পাঠানো হচ্ছে...' : 'Broadcasting...')
                        : (isBn ? 'এখনই ব্রডকাস্ট করুন' : 'Broadcast Notification Now'),
                    style: GoogleFonts.googleSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
