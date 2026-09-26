import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/embedded_map_preview.dart';

/// Admin CMS screen for managing Google Maps Embeds (HTML <iframe> or URLs)
/// across all places, tourist destinations, hospitals, emergency offices, and public services.
class AdminPlacesMapScreen extends ConsumerStatefulWidget {
  const AdminPlacesMapScreen({super.key});

  @override
  ConsumerState<AdminPlacesMapScreen> createState() => _AdminPlacesMapScreenState();
}

class _AdminPlacesMapScreenState extends ConsumerState<AdminPlacesMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'nameBn': 'সব ক্যাটাগরি', 'nameEn': 'All Categories'},
    {'id': 'tourism', 'nameBn': 'দর্শনীয় ও পর্যটন', 'nameEn': 'Tourism & Heritage'},
    {'id': 'healthcare', 'nameBn': 'হাসপাতাল ও ডাক্তার', 'nameEn': 'Healthcare'},
    {'id': 'police', 'nameBn': 'থানা ও পুলিশ', 'nameEn': 'Police Stations'},
    {'id': 'fire', 'nameBn': 'ফায়ার সার্ভিস', 'nameEn': 'Fire Service'},
    {'id': 'emergency', 'nameBn': 'জরুরি সেবা', 'nameEn': 'Emergency'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isBn ? 'অ্যাডমিন এক্সেস' : 'Admin Access'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                      ? 'ম্যাপ লোকেশন পরিচালনা করতে অ্যাডমিন একাউন্টে সাইন ইন করুন।'
                      : 'Please sign in with an authorized admin account to manage map locations.',
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
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isBn ? 'গুগল ম্যাপস লোকেশন পরিচালনা' : 'Google Maps Location Manager',
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isBn ? 'স্থান, হাসপাতাল বা প্রতিষ্ঠানের নাম খুঁজুন...' : 'Search place, hospital, office...',
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
                    final addr = (r.addressBn ?? '').toLowerCase();
                    return nameBn.contains(_searchQuery) ||
                        nameEn.contains(_searchQuery) ||
                        addr.contains(_searchQuery);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      isBn ? 'কোনো স্থান বা সেবা পাওয়া যায়নি' : 'No places or services found',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final item = filtered[idx];
                    final hasCustomEmbed = item.mapEmbedUrl != null && item.mapEmbedUrl!.trim().isNotEmpty;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: hasCustomEmbed
                              ? const Color(0xFF10B981).withAlpha(120)
                              : const Color(0xFFE2E8F0),
                          width: hasCustomEmbed ? 1.5 : 1.0,
                        ),
                      ),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showEditMapDialog(context, item, isBn),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Badge
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: hasCustomEmbed
                                          ? const Color(0xFFEAF5EE)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: hasCustomEmbed
                                          ? AppColors.primary
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.getName(isBn),
                                          style: GoogleFonts.googleSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        if (item.getAddress(isBn).isNotEmpty)
                                          Text(
                                            item.getAddress(isBn),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: hasCustomEmbed
                                          ? const Color(0xFFEAF5EE)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      hasCustomEmbed
                                          ? (isBn ? 'ম্যাপ লিংক যুক্ত' : 'Map Linked')
                                          : (isBn ? 'ম্যাপ লিংক নেই' : 'No Map Link'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: hasCustomEmbed
                                            ? AppColors.primary
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Map Link Status & Actions
                              Row(
                                children: [
                                  Icon(
                                    hasCustomEmbed
                                        ? Icons.check_circle_rounded
                                        : Icons.link_off_rounded,
                                    size: 15,
                                    color: hasCustomEmbed
                                        ? const Color(0xFF10B981)
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    hasCustomEmbed
                                        ? (isBn ? 'গুগল ম্যাপস লিংক সক্রিয়' : 'Google Maps Active')
                                        : (isBn ? 'কোনো ম্যাপ লিংক নেই' : 'No map link yet'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: hasCustomEmbed ? FontWeight.w600 : FontWeight.normal,
                                      color: hasCustomEmbed
                                          ? const Color(0xFF065F46)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => _showEditMapDialog(context, item, isBn),
                                    icon: const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primary),
                                    label: Text(
                                      hasCustomEmbed
                                          ? (isBn ? 'লিংক পরিবর্তন' : 'Change Link')
                                          : (isBn ? 'ম্যাপ লিংক দিন' : 'Add Map Link'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditMapDialog(BuildContext context, MasterRecord item, bool isBn) {
    final embedCtrl = TextEditingController(text: item.mapEmbedUrl ?? '');
    bool showLivePreview = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.map_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn ? '${item.getName(isBn)} — গুগল ম্যাপস লিংক' : 'Google Maps Link — ${item.getName(isBn)}',
                    style: GoogleFonts.googleSans(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Help Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'কীভাবে গুগল ম্যাপস লিংক নিবেন?' : 'How to get map link?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBn
                                ? '১. গুগল ম্যাপসে যান এবং স্থানটি খুঁজুন।\n২. Share বাটনে ক্লিক করে লিংক কপি করুন, অথবা "Embed a map" থেকে HTML কোড কপি করুন।\n৩. নিচের বক্সে লিংক বা কোডটি পেস্ট করে সংরক্ষণ করুন।'
                                : '1. Search the place on Google Maps.\n2. Click Share -> Copy link (or Embed a map -> Copy HTML).\n3. Paste into the box below and click Save.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Map Link / Code Text Area
                    Text(
                      isBn ? 'গুগল ম্যাপস লিংক / HTML কোড:' : 'Google Maps Link / HTML Code:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: embedCtrl,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'https://maps.app.goo.gl/... বা <iframe src="https://www.google.com/maps/embed?..."></iframe>',
                        hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onChanged: (_) {
                        if (showLivePreview) {
                          setDialogState(() {});
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Action: Search Google Maps Link & Preview Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final q = Uri.encodeComponent('${item.getName(isBn)}, Kushtia');
                            final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.travel_explore_rounded, size: 16),
                          label: Text(
                            isBn ? 'গুগল ম্যাপসে খুঁজুন' : 'Search on Google Maps',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: showLivePreview ? AppColors.primary : Colors.grey.shade400,
                            ),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              showLivePreview = !showLivePreview;
                            });
                          },
                          icon: Icon(
                            showLivePreview ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 16,
                            color: showLivePreview ? AppColors.primary : Colors.grey.shade700,
                          ),
                          label: Text(
                            showLivePreview
                                ? (isBn ? 'প্রিভিউ বন্ধ' : 'Hide Preview')
                                : (isBn ? 'লাইভ প্রিভিউ' : 'Live Preview'),
                            style: TextStyle(
                              fontSize: 12,
                              color: showLivePreview ? AppColors.primary : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Live Interactive Preview
                    if (showLivePreview) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 180,
                          child: EmbeddedMapPreview(
                            title: item.getName(isBn),
                            mapEmbedUrl: embedCtrl.text.trim().isNotEmpty ? embedCtrl.text.trim() : null,
                            height: 180,
                          ),
                        ),
                      ),
                    ],
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(ctx);
                  final embedValue = embedCtrl.text.trim();

                  try {
                    await _firestore.collection('records').doc(item.id).set({
                      'id': item.id,
                      'mapEmbedUrl': embedValue.isNotEmpty ? embedValue : null,
                      'updatedAt': DateTime.now().toIso8601String(),
                    }, SetOptions(merge: true));

                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isBn
                              ? 'গুগল ম্যাপস লিংক সফলভাবে সংরক্ষিত হয়েছে!'
                              : 'Google Maps link saved successfully!',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Error saving: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(isBn ? 'সংরক্ষণ করুন' : 'Save Link'),
              ),
            ],
          );
        },
      ),
    );
  }
}
