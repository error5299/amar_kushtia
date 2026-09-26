import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/seed_master_data.dart';
import '../../models/national_hotline.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_colors.dart';

/// Admin CMS for App Announcements, Banner Notices, and National/Emergency Hotlines
class AdminNoticeScreen extends ConsumerStatefulWidget {
  const AdminNoticeScreen({super.key});

  @override
  ConsumerState<AdminNoticeScreen> createState() => _AdminNoticeScreenState();
}

class _AdminNoticeScreenState extends ConsumerState<AdminNoticeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _noticeBnCtrl = TextEditingController();
  final TextEditingController _noticeEnCtrl = TextEditingController();
  bool _isNoticeActive = true;
  bool _isNoticeUrgent = false;
  bool _isLoadingNotice = true;
  bool _isSavingNotice = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentNotice();
  }

  Future<void> _loadCurrentNotice() async {
    try {
      final doc = await _firestore.collection('app_config').doc('global_notice').get();
      if (doc.exists) {
        final data = doc.data()!;
        _noticeBnCtrl.text = data['textBn'] as String? ?? data['text'] as String? ?? '';
        _noticeEnCtrl.text = data['textEn'] as String? ?? '';
        _isNoticeActive = data['enabled'] as bool? ?? data['isActive'] as bool? ?? true;
        _isNoticeUrgent = data['isUrgent'] as bool? ?? false;
      } else {
        _noticeBnCtrl.text = 'কুষ্টিয়া লালন মেলা ২০২৬ উপলক্ষ্যে বিশেষ বাস ও ট্রেন সার্ভিস চালু থাকবে। জরুরি প্রয়োজনে ৯৯৯ নম্বরে কল করুন।';
        _noticeEnCtrl.text = 'Special train and bus services are operational for Lalon Mela 2026. For emergencies call 999.';
      }
    } catch (_) {
      _noticeBnCtrl.text = 'কুষ্টিয়া লালন মেলা ২০২৬ উপলক্ষ্যে বিশেষ বাস ও ট্রেন সার্ভিস চালু থাকবে। জরুরি প্রয়োজনে ৯৯৯ নম্বরে কল করুন।';
    } finally {
      if (mounted) setState(() => _isLoadingNotice = false);
    }
  }

  Future<void> _saveNotice(bool isBn) async {
    setState(() => _isSavingNotice = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _firestore.collection('app_config').doc('global_notice').set({
        'text': _noticeBnCtrl.text.trim(),
        'textBn': _noticeBnCtrl.text.trim(),
        'textEn': _noticeEnCtrl.text.trim(),
        'enabled': _isNoticeActive,
        'isActive': _isNoticeActive,
        'isUrgent': _isNoticeUrgent,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      messenger.showSnackBar(
        SnackBar(
          content: Text(isBn ? 'নোটিশ সফলভাবে সংরক্ষিত ও লাইভ হয়েছে!' : 'Notice updated successfully!'),
          backgroundColor: const Color(0xFF0B5233),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSavingNotice = false);
    }
  }

  @override
  void dispose() {
    _noticeBnCtrl.dispose();
    _noticeEnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(isBn ? 'সংরক্ষিত' : 'Restricted')),
        body: const Center(child: Text('Admin access only')),
      );
    }

    final hotlinesAsync = ref.watch(nationalHotlinesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: Text(
          isBn ? 'নোটিশ ও হটলাইন ব্যবস্থাপনা' : 'Notice & Hotlines CMS',
          style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoadingNotice
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Announcement Banner Section ──
                  Container(
                    padding: const EdgeInsets.all(18),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.campaign_rounded, color: Color(0xFFD97706), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBn ? 'অ্যাপ হোম স্ক্রিন ব্যানার নোটিশ' : 'Home Screen Banner Notice',
                                    style: GoogleFonts.googleSans(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    isBn ? 'ব্যবহারকারীদের জন্য জরুরি বা সতর্কতামূলক বার্তা' : 'Broadcast alert or notice',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isBn ? 'নোটিশ সক্রিয় থাকবে' : 'Notice Banner Enabled',
                            style: GoogleFonts.googleSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          subtitle: Text(
                            isBn ? 'সুইচ অন থাকলে হোমপেজের শীর্ষে লাল/সবুজ ব্যানার দেখা যাবে' : 'Display banner on app home',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          value: _isNoticeActive,
                          onChanged: (val) => setState(() => _isNoticeActive = val),
                        ),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isBn ? 'জরুরি সতর্কবার্তা হিসেবে দেখান (লাল রঙ)' : 'Urgent Notice (Red style)',
                            style: GoogleFonts.googleSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          value: _isNoticeUrgent,
                          onChanged: (val) => setState(() => _isNoticeUrgent = val),
                        ),

                        const SizedBox(height: 10),
                        TextField(
                          controller: _noticeBnCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: isBn ? 'নোটিশ বার্তা (বাংলায়) *' : 'Notice Text (Bengali) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noticeEnCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: isBn ? 'নোটিশ বার্তা (ইংরেজি)' : 'Notice Text (English)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSavingNotice ? null : () => _saveNotice(isBn),
                            icon: _isSavingNotice
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              isBn ? 'নোটিশ সংরক্ষণ ও লাইভ করুন' : 'Save & Publish Notice',
                              style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── National & Local Hotlines Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'জরুরি হটলাইনসমূহ' : 'Emergency Hotlines',
                        style: GoogleFonts.googleSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      TextButton.icon(
                        onPressed: () => _showEditHotlineDialog(context, null, isBn),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(isBn ? 'হটলাইন যোগ' : 'Add Hotline'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  hotlinesAsync.when(
                    data: (hotlines) {
                      final effective = hotlines.isNotEmpty ? hotlines : SeedMasterData.nationalHotlines;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: effective.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final h = effective[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    h.dialNumber,
                                    style: GoogleFonts.googleSans(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFDC2626),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isBn ? h.serviceNameBn : h.serviceNameEn,
                                        style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        h.availability,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.blue),
                                  onPressed: () => _showEditHotlineDialog(context, h, isBn),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                  onPressed: () => _deleteHotline(h, isBn),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  void _showEditHotlineDialog(BuildContext context, NationalHotline? item, bool isBn) {
    final dialCtrl = TextEditingController(text: item?.dialNumber ?? '');
    final nameBnCtrl = TextEditingController(text: item?.serviceNameBn ?? '');
    final nameEnCtrl = TextEditingController(text: item?.serviceNameEn ?? '');
    final availCtrl = TextEditingController(text: item?.availability ?? '24/7');
    final descCtrl = TextEditingController(text: item?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item == null ? (isBn ? 'নতুন হটলাইন যোগ' : 'Add Hotline') : (isBn ? 'হটলাইন সম্পাদনা' : 'Edit Hotline')),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dialCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'ডায়াল নম্বর (যেমন: 999) *' : 'Dial Number *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameBnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'সেবার নাম (বাংলায়) *' : 'Service Name (Bengali) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameEnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'সেবার নাম (English)' : 'Service Name (English)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: availCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'কার্যসময় (যেমন: 24/7)' : 'Availability (e.g. 24/7)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'বিবরণ' : 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final dial = dialCtrl.text.trim();
              final nameBn = nameBnCtrl.text.trim();
              if (dial.isEmpty || nameBn.isEmpty) return;

              final docId = item?.id ?? 'HL-$dial';
              final data = {
                'id': docId,
                'dialNumber': dial,
                'serviceNameBn': nameBn,
                'serviceNameEn': nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : nameBn,
                'availability': availCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              };

              Navigator.pop(ctx);
              await _firestore.collection('national_hotlines').doc(docId).set(data, SetOptions(merge: true));
            },
            child: Text(isBn ? 'সংরক্ষণ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteHotline(NationalHotline h, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'হটলাইন মুছে ফেলতে চান?' : 'Delete Hotline?'),
        content: Text(isBn ? '${h.serviceNameBn} (${h.dialNumber}) মুছে ফেলবেন?' : 'Delete ${h.dialNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestore.collection('national_hotlines').doc(h.id).delete();
            },
            child: Text(isBn ? 'মুছে ফেলুন' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
