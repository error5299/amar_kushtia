import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/verification_badge.dart';

/// Comprehensive Master Records CMS Screen:
/// Provides full Add, Edit, Delete, Search, and Category Filtering for
/// all places, hospitals, doctors, tourist spots, emergency services, and offices.
class AdminMasterRecordsScreen extends ConsumerStatefulWidget {
  const AdminMasterRecordsScreen({super.key});

  @override
  ConsumerState<AdminMasterRecordsScreen> createState() => _AdminMasterRecordsScreenState();
}

class _AdminMasterRecordsScreenState extends ConsumerState<AdminMasterRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  static const List<Map<String, String>> _categories = [
    {'id': 'all', 'nameBn': 'সকল সেবা ও স্থান', 'nameEn': 'All Records'},
    {'id': 'emergency', 'nameBn': 'জরুরি সেবা', 'nameEn': 'Emergency'},
    {'id': 'healthcare', 'nameBn': 'স্বাস্থ্যসেবা ও ডাক্তার', 'nameEn': 'Healthcare'},
    {'id': 'tourism', 'nameBn': 'দর্শনীয় স্থান', 'nameEn': 'Tourism'},
    {'id': 'transport', 'nameBn': 'পরিবহন ও কাউন্টার', 'nameEn': 'Transport'},
    {'id': 'education', 'nameBn': 'শিক্ষা প্রতিষ্ঠান', 'nameEn': 'Education'},
    {'id': 'administration', 'nameBn': 'প্রশাসন ও সরকারি অফিস', 'nameEn': 'Administration'},
    {'id': 'police', 'nameBn': 'থানা ও পুলিশ', 'nameEn': 'Police'},
    {'id': 'fire', 'nameBn': 'ফায়ার সার্ভিস', 'nameEn': 'Fire Service'},
    {'id': 'food', 'nameBn': 'খাবার ও মিষ্টি', 'nameEn': 'Food & Sweets'},
    {'id': 'craft', 'nameBn': 'ঐতিহ্যবাহী তাঁত ও পণ্য', 'nameEn': 'Craft & GI'},
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isBn ? 'অ্যাডমিন এক্সেস সংরক্ষিত' : 'Restricted Access'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 60, color: Color(0xFF0B5233)),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'শুধুমাত্র অ্যাডমিনদের জন্য সংরক্ষিত' : 'Restricted to Administrators',
                  style: GoogleFonts.googleSans(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'তথ্য পরিবর্তন বা নতুন তথ্য যুক্ত করতে অনুগ্রহ করে অনুমোদিত অ্যাডমিন একাউন্টে সাইন ইন করুন।'
                      : 'Please sign in with an authorized admin account to manage records.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recordsAsync = ref.watch(masterRecordsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: Text(
          isBn ? 'স্থান ও সেবা তথ্য পরিচালনা' : 'Places & Services CMS',
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(
          isBn ? 'নতুন তথ্য যুক্ত করুন' : 'Add New Record',
          style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
        ),
        onPressed: () => showEditMasterRecordDialog(context, null, isBn),
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isBn ? 'নাম, ঠিকানা, ফোন নম্বর বা ক্যাটাগরি খুঁজুন...' : 'Search by name, address, phone...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(isBn ? cat['nameBn']! : cat['nameEn']!),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                          ),
                          onSelected: (sel) {
                            if (sel) {
                              setState(() {
                                _selectedCategory = cat['id']!;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Records List ──
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                var filtered = records;
                if (_selectedCategory != 'all') {
                  filtered = filtered
                      .where((r) => r.categoryId.toLowerCase() == _selectedCategory.toLowerCase())
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((r) {
                    final nameBn = r.nameBn.toLowerCase();
                    final nameEn = (r.nameEn ?? '').toLowerCase();
                    final addrBn = (r.addressBn ?? '').toLowerCase();
                    final phone = (r.phonePrimary ?? '').toLowerCase();
                    final subcat = (r.subcategoryId ?? '').toLowerCase();
                    return nameBn.contains(_searchQuery) ||
                        nameEn.contains(_searchQuery) ||
                        addrBn.contains(_searchQuery) ||
                        phone.contains(_searchQuery) ||
                        subcat.contains(_searchQuery);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isBn ? 'কোনো তথ্য পাওয়া যায়নি' : 'No records found',
                            style: GoogleFonts.googleSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final item = filtered[idx];
                    final hasMap = item.mapEmbedUrl != null && item.mapEmbedUrl!.trim().isNotEmpty;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Name & Badges
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.getName(isBn),
                                        style: GoogleFonts.googleSans(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      if (item.subcategoryId != null && item.subcategoryId!.isNotEmpty)
                                        Text(
                                          item.subcategoryId!,
                                          style: GoogleFonts.googleSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                VerificationBadge(status: item.verificationStatus, compact: true),
                              ],
                            ),

                            if (item.getAddress(isBn).isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.getAddress(isBn),
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (item.phonePrimary != null && item.phonePrimary!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.phonePrimary!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 8),

                            // Footer Row: Map Status & Actions
                            Row(
                              children: [
                                Icon(
                                  hasMap ? Icons.check_circle_rounded : Icons.link_off_rounded,
                                  size: 14,
                                  color: hasMap ? const Color(0xFF10B981) : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasMap
                                      ? (isBn ? 'ম্যাপ যুক্ত' : 'Map Linked')
                                      : (isBn ? 'ম্যাপ নেই' : 'No Map'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: hasMap ? const Color(0xFF065F46) : Colors.grey.shade600,
                                    fontWeight: hasMap ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                // Edit Button
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => showEditMasterRecordDialog(context, item, isBn),
                                  icon: const Icon(Icons.edit_rounded, size: 14),
                                  label: Text(
                                    isBn ? 'সম্পাদনা' : 'Edit',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                  tooltip: isBn ? 'মুছে ফেলুন' : 'Delete',
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _confirmDeleteRecord(context, item, isBn),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, MasterRecord item, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'মুছে ফেলার নিশ্চিতকরণ' : 'Confirm Delete'),
        content: Text(
          isBn
              ? 'আপনি কি নিশ্চিত যে "${item.getName(isBn)}" তালিকা থেকে স্থায়ীভাবে মুছে ফেলতে চান?'
              : 'Are you sure you want to permanently delete "${item.getName(isBn)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _firestore.collection('records').doc(item.id).delete();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isBn ? 'তথ্য সফলভাবে মুছে ফেলা হয়েছে।' : 'Record deleted successfully.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(isBn ? 'মুছে ফেলুন' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

/// Global Universal Dialog for adding or editing any MasterRecord
void showEditMasterRecordDialog(BuildContext context, MasterRecord? item, bool isBn) {
  final nameBnCtrl = TextEditingController(text: item?.nameBn ?? '');
  final nameEnCtrl = TextEditingController(text: item?.nameEn ?? '');
  final phoneCtrl = TextEditingController(text: item?.phonePrimary ?? '');
  final addrBnCtrl = TextEditingController(text: item?.addressBn ?? '');
  final addrEnCtrl = TextEditingController(text: item?.addressEn ?? '');
  final descBnCtrl = TextEditingController(text: item?.descriptionBn ?? item?.shortDescriptionBn ?? '');
  final mapUrlCtrl = TextEditingController(text: item?.mapEmbedUrl ?? '');
  final websiteCtrl = TextEditingController(text: item?.website ?? '');
  final imagesCtrl = TextEditingController(text: item?.imageUrls.join(', ') ?? '');
  final subcategoryCtrl = TextEditingController(text: item?.subcategoryId ?? '');

  String selectedCategory = item?.categoryId ?? 'healthcare';
  String selectedUpazila = item?.upazilaId ?? 'UPZ-002';
  String selectedVerification = item?.verificationStatus ?? 'Verified';

  final firestore = FirebaseFirestore.instance;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogCtx, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(item == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item == null
                      ? (isBn ? 'নতুন তথ্য যুক্ত করুন' : 'Add New Record')
                      : (isBn ? '${item.getName(isBn)} — সম্পাদনা' : 'Edit — ${item.getName(isBn)}'),
                  style: GoogleFonts.googleSans(fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bengali Name
                  TextField(
                    controller: nameBnCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'নাম (বাংলা) *' : 'Name (Bengali) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // English Name
                  TextField(
                    controller: nameEnCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'নাম (ইংরেজি)' : 'Name (English)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category & Subcategory Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: isBn ? 'বিভাগ (Category)' : 'Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'healthcare', child: Text('স্বাস্থ্যসেবা ও হাসপাতাল')),
                            DropdownMenuItem(value: 'emergency', child: Text('জরুরি সেবা')),
                            DropdownMenuItem(value: 'tourism', child: Text('দর্শনীয় স্থান ও পার্ক')),
                            DropdownMenuItem(value: 'transport', child: Text('পরিবহন ও কাউন্টার')),
                            DropdownMenuItem(value: 'education', child: Text('শিক্ষা প্রতিষ্ঠান')),
                            DropdownMenuItem(value: 'administration', child: Text('প্রশাসন ও সরকারি')),
                            DropdownMenuItem(value: 'police', child: Text('থানা ও পুলিশ')),
                            DropdownMenuItem(value: 'fire', child: Text('ফায়ার সার্ভিস')),
                            DropdownMenuItem(value: 'food', child: Text('খাবার ও মিষ্টান্ন')),
                            DropdownMenuItem(value: 'craft', child: Text('ঐতিহ্যবাহী তাঁত ও শিল্প')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedCategory = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: subcategoryCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'উপ-বিভাগ' : 'Subcategory',
                            hintText: 'e.g. জেনারেল হাসপাতাল',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Upazila & Verification Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUpazila,
                          decoration: InputDecoration(
                            labelText: isBn ? 'উপজেলা' : 'Upazila',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'UPZ-002', child: Text('কুষ্টিয়া সদর')),
                            DropdownMenuItem(value: 'UPZ-004', child: Text('কুমারখালী')),
                            DropdownMenuItem(value: 'UPZ-005', child: Text('ভেড়ামারা')),
                            DropdownMenuItem(value: 'UPZ-003', child: Text('মিরপুর')),
                            DropdownMenuItem(value: 'UPZ-001', child: Text('দৌলতপুর')),
                            DropdownMenuItem(value: 'UPZ-006', child: Text('খোকসা')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedUpazila = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedVerification,
                          decoration: InputDecoration(
                            labelText: isBn ? 'যাচাই স্ট্যাটাস' : 'Status',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Verified', child: Text('Verified (যাচাইকৃত)')),
                            DropdownMenuItem(value: 'Partially Verified', child: Text('Partially Verified')),
                            DropdownMenuItem(value: 'Official', child: Text('Official (সরকারি)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedVerification = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Phone Number
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isBn ? 'যোগাযোগের ফোন নম্বর' : 'Phone Number',
                      hintText: '০১৭xxxxxxxx বা ০৯৬xxxxxxx',
                      prefixIcon: const Icon(Icons.phone_rounded, size: 18, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Address
                  TextField(
                    controller: addrBnCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ঠিকানা (বাংলা)' : 'Address (Bengali)',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Google Maps Link / Embed Code
                  TextField(
                    controller: mapUrlCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: isBn ? 'গুগল ম্যাপস লিংক বা HTML কোড' : 'Google Maps Link or HTML',
                      hintText: 'https://maps.app.goo.gl/... বা <iframe src="..."></iframe>',
                      prefixIcon: const Icon(Icons.map_rounded, size: 18, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Image URLs (comma separated)
                  TextField(
                    controller: imagesCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ছবির লিংক (URL, কমা দিয়ে একাধিক)' : 'Image URLs (comma separated)',
                      prefixIcon: const Icon(Icons.image_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Website URL
                  TextField(
                    controller: websiteCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ওয়েবসাইট লিংক' : 'Website Link',
                      hintText: 'https://...',
                      prefixIcon: const Icon(Icons.language_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  TextField(
                    controller: descBnCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: isBn ? 'বিবরণ ও সেবার তথ্য' : 'Description & Details',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isBn ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () async {
                final nameBn = nameBnCtrl.text.trim();
                if (nameBn.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isBn ? 'দয়া করে নাম লিখুন।' : 'Please enter a name.')),
                  );
                  return;
                }

                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);

                final id = item?.id ?? 'MD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
                final imgUrls = imagesCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final payload = <String, dynamic>{
                  'id': id,
                  'nameBn': nameBn,
                  'nameEn': nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : null,
                  'categoryId': selectedCategory,
                  'subcategoryId': subcategoryCtrl.text.trim().isNotEmpty ? subcategoryCtrl.text.trim() : null,
                  'upazilaId': selectedUpazila,
                  'phonePrimary': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                  'addressBn': addrBnCtrl.text.trim().isNotEmpty ? addrBnCtrl.text.trim() : null,
                  'addressEn': addrEnCtrl.text.trim().isNotEmpty ? addrEnCtrl.text.trim() : null,
                  'descriptionBn': descBnCtrl.text.trim().isNotEmpty ? descBnCtrl.text.trim() : null,
                  'shortDescriptionBn': descBnCtrl.text.trim().isNotEmpty ? descBnCtrl.text.trim() : null,
                  'mapEmbedUrl': mapUrlCtrl.text.trim().isNotEmpty ? mapUrlCtrl.text.trim() : null,
                  'website': websiteCtrl.text.trim().isNotEmpty ? websiteCtrl.text.trim() : null,
                  'verificationStatus': selectedVerification,
                  'imageUrls': imgUrls,
                  'isActive': true,
                  'updatedAt': DateTime.now().toIso8601String(),
                };

                try {
                  await firestore.collection('records').doc(id).set(payload, SetOptions(merge: true));
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isBn
                            ? 'তথ্য সফলভাবে সংরক্ষিত হয়েছে!'
                            : 'Record saved successfully!',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(isBn ? 'সংরক্ষণ করুন' : 'Save Record'),
            ),
          ],
        );
      },
    ),
  );
}
