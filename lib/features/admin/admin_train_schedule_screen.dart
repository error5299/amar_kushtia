import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/seed_master_data.dart';
import '../../models/transport_tables.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_colors.dart';

/// Admin CMS for Western Railway Train Schedules (টাইম টেবিল নং-৫৪)
class AdminTrainScheduleScreen extends ConsumerStatefulWidget {
  const AdminTrainScheduleScreen({super.key});

  @override
  ConsumerState<AdminTrainScheduleScreen> createState() => _AdminTrainScheduleScreenState();
}

class _AdminTrainScheduleScreenState extends ConsumerState<AdminTrainScheduleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedType = 'all';

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
                      ? 'ট্রেনের শিডিউল পরিবর্তনের জন্য অনুগ্রহ করে অনুমোদিত অ্যাডমিন একাউন্টে সাইন ইন করুন।'
                      : 'Please sign in with an admin account to manage train timetables.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final trainsAsync = ref.watch(trainSchedulesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: Text(
          isBn ? 'ট্রেন সময়সূচি ব্যবস্থাপনা' : 'Train Schedule CMS',
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0B5233),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isBn ? 'নতুন ট্রেন যোগ করুন' : 'Add Train',
          style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
        ),
        onPressed: () => showEditTrainDialog(context, null, isBn),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isBn ? 'ট্রেনের নাম, নম্বর বা গন্তব্য খুঁজুন...' : 'Search train name, number...',
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
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      {'id': 'all', 'name': isBn ? 'সকল ট্রেন' : 'All Trains'},
                      {'id': 'আন্তঃনগর', 'name': isBn ? 'আন্তঃনগর (Intercity)' : 'Intercity'},
                      {'id': 'মেইল', 'name': isBn ? 'মেইল / এক্সপ্রেস' : 'Mail / Express'},
                      {'id': 'কমিউটার', 'name': isBn ? 'কমিউটার / শাটল' : 'Commuter'},
                    ].map((type) {
                      final isSelected = _selectedType == type['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type['name']!),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                          onSelected: (_) {
                            setState(() => _selectedType = type['id']!);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List of Trains
          Expanded(
            child: trainsAsync.when(
              data: (trains) {
                final effectiveList = trains.isNotEmpty ? trains : SeedMasterData.trainSchedules;
                final filtered = effectiveList.where((t) {
                  if (_selectedType != 'all') {
                    if (!t.trainType.toLowerCase().contains(_selectedType.toLowerCase())) {
                      return false;
                    }
                  }
                  if (_searchQuery.isNotEmpty) {
                    final matchName = t.trainNameBn.toLowerCase().contains(_searchQuery) ||
                        t.trainNameEn.toLowerCase().contains(_searchQuery);
                    final matchNo = t.trainNumber.toLowerCase().contains(_searchQuery);
                    final matchRoute = t.origin.toLowerCase().contains(_searchQuery) ||
                        t.destination.toLowerCase().contains(_searchQuery);
                    if (!matchName && !matchNo && !matchRoute) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      isBn ? 'কোনো ট্রেন পাওয়া যায়নি' : 'No trains found',
                      style: GoogleFonts.googleSans(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final train = filtered[i];
                    return _buildTrainCard(train, isBn);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainCard(TrainRecord train, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  train.trainNumber,
                  style: GoogleFonts.googleSans(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B5233),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn ? train.trainNameBn : train.trainNameEn,
                  style: GoogleFonts.googleSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                tooltip: isBn ? 'সম্পাদনা' : 'Edit',
                onPressed: () => showEditTrainDialog(context, train, isBn),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                tooltip: isBn ? 'মুছে ফেলুন' : 'Delete',
                onPressed: () => _confirmDeleteTrain(train, isBn),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${train.origin} ➔ ${train.destination}',
                  style: GoogleFonts.googleSans(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'ধরন: ${train.trainType}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              Text(
                'ছুটির দিন: ${train.offDayBn.isNotEmpty ? train.offDayBn : "ছুটি নেই"}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              if (train.departureTime.isNotEmpty)
                Text(
                  'সময়: ${train.departureTime}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTrain(TrainRecord train, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'ট্রেন মুছে ফেলতে চান?' : 'Delete Train?'),
        content: Text(isBn
            ? '${train.trainNameBn} (${train.trainNumber}) মুছে ফেলবেন?'
            : 'Are you sure you want to delete ${train.trainNameEn}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestore.collection('transport_schedules').doc(train.id).delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBn ? 'ট্রেন সফলভাবে মুছে ফেলা হয়েছে' : 'Train deleted successfully')),
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

/// Global Dialog for adding or editing a TrainRecord
void showEditTrainDialog(BuildContext context, TrainRecord? item, bool isBn) {
  final noCtrl = TextEditingController(text: item?.trainNumber ?? '');
  final nameBnCtrl = TextEditingController(text: item?.trainNameBn ?? '');
  final nameEnCtrl = TextEditingController(text: item?.trainNameEn ?? '');
  final typeCtrl = TextEditingController(text: item?.trainType ?? 'আন্তঃনগর');
  final originCtrl = TextEditingController(text: item?.origin ?? '');
  final destCtrl = TextEditingController(text: item?.destination ?? '');
  final depTimeCtrl = TextEditingController(text: item?.departureTime ?? '');
  final arrTimeCtrl = TextEditingController(text: item?.arrivalTime ?? '');
  final offDayCtrl = TextEditingController(text: item?.offDayBn ?? 'নেই');

  final firestore = FirebaseFirestore.instance;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogCtx, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.train_rounded, color: Color(0xFF0B5233)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item == null
                      ? (isBn ? 'নতুন ট্রেন যোগ করুন' : 'Add New Train')
                      : (isBn ? '${item.trainNameBn} সম্পাদনা' : 'Edit ${item.trainNameEn}'),
                  style: GoogleFonts.googleSans(fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ট্রেন নম্বর (যেমন: 761) *' : 'Train Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameBnCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ট্রেনের নাম (বাংলায়) *' : 'Train Name (Bengali) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameEnCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ট্রেনের নাম (ইংরেজি)' : 'Train Name (English)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: originCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'প্রারম্ভিক স্টেশন' : 'Origin Station',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: destCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'গন্তব্য স্টেশন' : 'Destination Station',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: depTimeCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'ছাড়ার সময়' : 'Departure Time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: arrTimeCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'পৌঁছানোর সময়' : 'Arrival Time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: typeCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'ট্রেনের ধরন (আন্তঃনগর/মেইল)' : 'Train Type',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: offDayCtrl,
                          decoration: InputDecoration(
                            labelText: isBn ? 'ছুটির দিন' : 'Off Day',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5233),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final no = noCtrl.text.trim();
                final nameBn = nameBnCtrl.text.trim();
                if (no.isEmpty || nameBn.isEmpty) return;

                final docId = item?.id ?? 'TR-$no';
                final data = {
                  'id': docId,
                  'trainNumber': no,
                  'trainNameBn': nameBn,
                  'trainNameEn': nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : nameBn,
                  'trainType': typeCtrl.text.trim(),
                  'origin': originCtrl.text.trim(),
                  'destination': destCtrl.text.trim(),
                  'departureTime': depTimeCtrl.text.trim(),
                  'arrivalTime': arrTimeCtrl.text.trim(),
                  'offDayBn': offDayCtrl.text.trim(),
                  'offDayEn': offDayCtrl.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);

                try {
                  await firestore.collection('transport_schedules').doc(docId).set(data, SetOptions(merge: true));
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(isBn ? 'ট্রেনের তথ্য সফলভাবে সংরক্ষিত হয়েছে' : 'Train timetable saved successfully'),
                      backgroundColor: const Color(0xFF0B5233),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
              child: Text(isBn ? 'সংরক্ষণ করুন' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
}
