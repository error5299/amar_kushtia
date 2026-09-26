import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations.dart';
import '../../models/app_notification.dart';
import '../../models/travel_guide_models.dart';
import '../../repositories/records_repository.dart';
import '../../services/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';


class AdminTravelGuideScreen extends ConsumerStatefulWidget {
  const AdminTravelGuideScreen({super.key});

  @override
  ConsumerState<AdminTravelGuideScreen> createState() => _AdminTravelGuideScreenState();
}

class _AdminTravelGuideScreenState extends ConsumerState<AdminTravelGuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                const Icon(Icons.admin_panel_settings_rounded, size: 64, color: Color(0xFF0B5233)),
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
                      ? 'ভ্রমণ গাইড ব্যবস্থাপনা প্যানেল শুধুমাত্র অনুমোদিত অ্যাডমিন অ্যাকাউন্ট দিয়ে পরিচালনা করা যায়।'
                      : 'The Travel Guide CMS can only be accessed with an authorized administrator account.',
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
          isBn ? 'ভ্রমণ গাইড ব্যবস্থাপনা (CMS)' : 'Travel Guide CMS',
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: isBn ? 'লোকাল রুট ও ভাড়া' : 'Local Routes & Fares'),
            Tab(text: isBn ? 'গন্তব্যসমূহ' : 'Destinations'),
            Tab(text: isBn ? 'বাস অপারেটর ও কাউন্টার' : 'Operators & Counters'),
            Tab(text: isBn ? 'অপারেটর-গন্তব্য রুট' : 'Operator Routes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalRoutesManager(isBn),
          _buildDestinationsManager(isBn),
          _buildOperatorsManager(isBn),
          _buildOperatorDestinationRoutesManager(isBn),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: LOCAL ROUTES, STOPS & FARES MANAGER
  // ===========================================================================
  Widget _buildLocalRoutesManager(bool isBn) {
    final routesAsync = ref.watch(localRoutesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditRouteDialog(context, null, isBn),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন রুট' : 'Add Route',
          style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (routes) {
          if (routes.isEmpty) {
            return Center(
              child: Text(isBn ? 'কোনো রুট নেই' : 'No routes found'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: ExpansionTile(
                  title: Text(
                    route.getTitle(isBn),
                    style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${route.origin} ➔ ${route.destination} • ${route.stops.length} টি স্টপ • ${route.fares.length} টি ফেয়ার জোড়া',
                    style: GoogleFonts.googleSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: isBn ? 'রুট এডিট' : 'Edit Route',
                        onPressed: () => _showEditRouteDialog(context, route, isBn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: isBn ? 'রুট ডিলিট' : 'Delete Route',
                        onPressed: () => _confirmDelete(
                          context,
                          'travel_local_routes',
                          route.id,
                          route.nameBn,
                          isBn,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    // Stops & Fares management bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: const Color(0xFFF8FAFC),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'স্টপ ও সেগমেন্ট তালিকা:' : 'Stops & Segments:',
                            style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                                label: Text(isBn ? 'স্টপ যোগ' : 'Add Stop', style: const TextStyle(fontSize: 12)),
                                onPressed: () => _showAddStopDialog(context, route, isBn),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.price_change_rounded, size: 16),
                                label: Text(isBn ? 'ভাড়া নির্ধারণ' : 'Set Fare', style: const TextStyle(fontSize: 12)),
                                onPressed: () => _showAddFareDialog(context, route, isBn),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Ordered stops chips list
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'স্টপের ক্রম:' : 'Ordered Stops:',
                            style: GoogleFonts.googleSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: route.sortedStops.map((stop) {
                              return Chip(
                                backgroundColor: AppColors.primaryContainer,
                                avatar: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Text('${stop.sequence}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                                label: Text(stop.getName(isBn), style: GoogleFonts.googleSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _deleteStopFromRoute(route, stop.id, isBn),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Fares List
                    if (route.fares.isNotEmpty) ...[
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'নির্ধারিত ভাড়া জোড়াসমূহ:' : 'Direct Pair Fares:',
                              style: GoogleFonts.googleSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: route.fares.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 4),
                              itemBuilder: (context, fIndex) {
                                final fareItem = route.fares[fIndex];
                                final fromStopName = route.stops.firstWhere((s) => s.id == fareItem.fromStopId, orElse: () => RouteStop(id: fareItem.fromStopId, nameBn: fareItem.fromStopId, nameEn: fareItem.fromStopId, sequence: 0)).getName(isBn);
                                final toStopName = route.stops.firstWhere((s) => s.id == fareItem.toStopId, orElse: () => RouteStop(id: fareItem.toStopId, nameBn: fareItem.toStopId, nameEn: fareItem.toStopId, sequence: 0)).getName(isBn);

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$fromStopName ➔ $toStopName', style: GoogleFonts.googleSans(fontSize: 12.5, fontWeight: FontWeight.w500)),
                                      Row(
                                        children: [
                                          Text('৳${fareItem.fare.toStringAsFixed(0)}', style: GoogleFonts.googleSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _deleteFareFromRoute(route, fareItem, isBn),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // TAB 2: DESTINATIONS MANAGER
  // ===========================================================================
  Widget _buildDestinationsManager(bool isBn) {
    final destsAsync = ref.watch(travelDestinationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditDestinationDialog(context, null, isBn),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন গন্তব্য' : 'Add Destination',
          style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: destsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (destinations) {
          if (destinations.isEmpty) {
            return Center(
              child: Text(isBn ? 'কোনো গন্তব্য নেই' : 'No destinations found'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: destinations.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  title: Text(
                    dest.getName(isBn),
                    style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${dest.nameEn} • বিভাগ: ${dest.division ?? 'অন্যান্য'}',
                    style: GoogleFonts.googleSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDestinationDialog(context, dest, isBn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                          context,
                          'travel_destinations',
                          dest.id,
                          dest.nameBn,
                          isBn,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // TAB 3: OPERATORS & COUNTERS MANAGER
  // ===========================================================================
  Widget _buildOperatorsManager(bool isBn) {
    final opsAsync = ref.watch(busOperatorsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditOperatorDialog(context, null, isBn),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন অপারেটর' : 'Add Operator',
          style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: opsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (operators) {
          if (operators.isEmpty) {
            return Center(
              child: Text(isBn ? 'কোনো বাস অপারেটর নেই' : 'No operators found'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: operators.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final op = operators[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: ExpansionTile(
                  title: Text(
                    op.getName(isBn),
                    style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${op.nameEn} • কাউন্টার: ${op.counters.length}টি',
                    style: GoogleFonts.googleSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_business_rounded, color: Colors.green),
                        tooltip: isBn ? 'কাউন্টার যোগ করুন' : 'Add Counter',
                        onPressed: () => _showEditCounterDialog(context, op, null, isBn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: isBn ? 'অপারেটর এডিট' : 'Edit Operator',
                        onPressed: () => _showEditOperatorDialog(context, op, isBn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: isBn ? 'অপারেটর ডিলিট' : 'Delete Operator',
                        onPressed: () => _confirmDelete(
                          context,
                          'travel_bus_operators',
                          op.id,
                          op.nameBn,
                          isBn,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (op.counters.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          isBn ? 'কোনো কাউন্টার যোগ করা হয়নি। উপরে ➕ বাটনে ট্যাপ করে কাউন্টার যোগ করুন।' : 'No counters added yet.',
                          style: GoogleFonts.googleSans(fontSize: 12, color: Colors.grey),
                        ),
                      )
                    else
                      ...op.counters.map((c) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.storefront, size: 20, color: AppColors.primary),
                            title: Text(c.name, style: GoogleFonts.googleSans(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${c.getAddress(isBn)} • ফোন: ${c.phonePrimary}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  onPressed: () => _showEditCounterDialog(context, op, c, isBn),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  onPressed: () => _deleteCounterFromOperator(op, c.id, isBn),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // TAB 4: OPERATOR-DESTINATION ROUTES MAPPING MANAGER
  // ===========================================================================
  Widget _buildOperatorDestinationRoutesManager(bool isBn) {
    final opRoutesAsync = ref.watch(operatorDestinationRoutesProvider);
    final opsAsync = ref.watch(busOperatorsProvider);
    final destsAsync = ref.watch(travelDestinationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditOpRouteDialog(context, null, isBn),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন রুট লিংক' : 'Link Route',
          style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: opRoutesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (routes) {
          final operators = opsAsync.valueOrNull ?? [];
          final destinations = destsAsync.valueOrNull ?? [];

          if (routes.isEmpty) {
            return Center(
              child: Text(isBn ? 'কোনো অপারেটর-গন্তব্য রুট নেই' : 'No operator routes found'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = routes[index];
              final opName = operators.firstWhere((o) => o.id == r.operatorId, orElse: () => BusOperator(id: r.operatorId, nameBn: r.operatorId, nameEn: r.operatorId)).getName(isBn);
              final destName = destinations.firstWhere((d) => d.id == r.destinationId, orElse: () => TravelDestination(id: r.destinationId, nameBn: r.destinationId, nameEn: r.destinationId, normalizedName: r.destinationId)).getName(isBn);

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  title: Text(
                    '$opName ➔ $destName',
                    style: GoogleFonts.googleSans(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'সার্ভিস: ${r.serviceStatus} • যাত্রা পয়েন্ট: ${r.startingCounterName ?? 'কুষ্টিয়া কাউন্টার'}',
                    style: GoogleFonts.googleSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditOpRouteDialog(context, r, isBn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                          context,
                          'travel_operator_destinations',
                          r.id,
                          '$opName - $destName',
                          isBn,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // DIALOGS & MUTATIONS
  // ===========================================================================

  void _confirmDelete(
    BuildContext context,
    String collection,
    String docId,
    String itemName,
    bool isBn,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'মুছে ফেলতে নিশ্চিত?' : 'Confirm Delete'),
        content: Text(
          isBn
              ? 'আপনি কি "$itemName" মুছে ফেলতে চান?'
              : 'Are you sure you want to delete "$itemName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await _firestore.collection(collection).doc(docId).delete();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isBn ? 'সফলভাবে মুছে ফেলা হয়েছে' : 'Deleted successfully'),
                ),
              );
            },
            child: Text(isBn ? 'মুছে ফেলুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 1. Edit Route Dialog
  void _showEditRouteDialog(BuildContext context, LocalRoute? route, bool isBn) {
    final nameBnCtrl = TextEditingController(text: route?.nameBn ?? '');
    final nameEnCtrl = TextEditingController(text: route?.nameEn ?? '');
    final originCtrl = TextEditingController(text: route?.origin ?? '');
    final destCtrl = TextEditingController(text: route?.destination ?? '');
    bool sameReverse = route?.sameReverseFare ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            route == null
                ? (isBn ? 'নতুন লোকাল রুট তৈরি' : 'Create Local Route')
                : (isBn ? 'রুট সম্পাদন' : 'Edit Local Route'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameBnCtrl,
                  decoration: InputDecoration(
                    labelText: isBn ? 'রুটের নাম (বাংলা)' : 'Route Name (Bangla)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameEnCtrl,
                  decoration: InputDecoration(
                    labelText: isBn ? 'রুটের নাম (ইংরেজি)' : 'Route Name (English)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: originCtrl,
                  decoration: InputDecoration(
                    labelText: isBn ? 'শুরুর স্থান' : 'Origin',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: destCtrl,
                  decoration: InputDecoration(
                    labelText: isBn ? 'গন্তব্য স্থান' : 'Destination',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    isBn ? 'উভয়মুখী ভাড়া একই' : 'Same Reverse Fare',
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: sameReverse,
                  onChanged: (val) {
                    setDialogState(() => sameReverse = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isBn ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameBnCtrl.text.trim().isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final docId = route?.id ??
                    _firestore.collection('travel_local_routes').doc().id;

                final data = {
                  'id': docId,
                  'nameBn': nameBnCtrl.text.trim(),
                  'nameEn': nameEnCtrl.text.trim().isNotEmpty
                      ? nameEnCtrl.text.trim()
                      : nameBnCtrl.text.trim(),
                  'origin': originCtrl.text.trim(),
                  'destination': destCtrl.text.trim(),
                  'sameReverseFare': sameReverse,
                  'isPublished': true,
                  'isActive': true,
                  'stops': route?.stops.map((s) => s.toMap()).toList() ?? [],
                  'fares': route?.fares.map((f) => f.toMap()).toList() ?? [],
                };

                final isNewRoute = route == null;

                await _firestore
                    .collection('travel_local_routes')
                    .doc(docId)
                    .set(data, SetOptions(merge: true));

                // Auto-broadcast notification for new route
                if (isNewRoute) {
                  NotificationService.sendNotification(
                    titleBn: 'নতুন বাস রুট: ${nameBnCtrl.text.trim()}',
                    titleEn: 'New Bus Route: ${nameEnCtrl.text.trim()}',
                    bodyBn: '${originCtrl.text.trim()} থেকে ${destCtrl.text.trim()} রুটের বাস ভাড়ার তালিকা যুক্ত করা হয়েছে।',
                    bodyEn: 'Bus fare information for route from ${originCtrl.text.trim()} to ${destCtrl.text.trim()} has been updated.',
                    type: NotificationType.travel,
                    targetRoute: 'travel_guide',
                  ).catchError((_) {});
                }

                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      isBn ? 'রুট সংরক্ষিত হয়েছে' : 'Route saved successfully',
                    ),
                  ),
                );
              },
              child: Text(
                isBn ? 'সংরক্ষণ' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Add Stop to Route Dialog
  void _showAddStopDialog(BuildContext context, LocalRoute route, bool isBn) {
    final nameBnCtrl = TextEditingController();
    final nameEnCtrl = TextEditingController();
    final seqCtrl = TextEditingController(text: '${route.stops.length + 1}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'রুটে নতুন স্টপ যোগ করুন' : 'Add Stop to Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameBnCtrl,
              decoration: InputDecoration(labelText: isBn ? 'স্টপের নাম (বাংলা)' : 'Stop Name (Bangla)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameEnCtrl,
              decoration: InputDecoration(labelText: isBn ? 'স্টপের নাম (ইংরেজি)' : 'Stop Name (English)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: seqCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: isBn ? 'ক্রমিক নম্বর (Sequence)' : 'Sequence No'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameBnCtrl.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);

              final newStop = RouteStop(
                id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
                nameBn: nameBnCtrl.text.trim(),
                nameEn: nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : nameBnCtrl.text.trim(),
                sequence: int.tryParse(seqCtrl.text.trim()) ?? (route.stops.length + 1),
              );

              final updatedStops = List<RouteStop>.from(route.stops)..add(newStop);

              await _firestore.collection('travel_local_routes').doc(route.id).update({
                'stops': updatedStops.map((s) => s.toMap()).toList(),
              });

              nav.pop();
              messenger.showSnackBar(SnackBar(content: Text(isBn ? 'স্টপ যোগ করা হয়েছে' : 'Stop added successfully')));
            },
            child: Text(isBn ? 'যোগ করুন' : 'Add', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStopFromRoute(LocalRoute route, String stopId, bool isBn) async {
    final updatedStops = route.stops.where((s) => s.id != stopId).toList();
    final updatedFares = route.fares.where((f) => f.fromStopId != stopId && f.toStopId != stopId).toList();

    await _firestore.collection('travel_local_routes').doc(route.id).update({
      'stops': updatedStops.map((s) => s.toMap()).toList(),
      'fares': updatedFares.map((f) => f.toMap()).toList(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBn ? 'স্টপ মুছে ফেলা হয়েছে' : 'Stop removed')));
    }
  }

  // 3. Add Fare Pair to Route Dialog
  void _showAddFareDialog(BuildContext context, LocalRoute route, bool isBn) {
    if (route.stops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBn ? 'ভাড়া নির্ধারণের জন্য অন্তত ২টি স্টপ প্রয়োজন' : 'At least 2 stops are required to set fares')),
      );
      return;
    }

    String fromStopId = route.sortedStops.first.id;
    String toStopId = route.sortedStops[1].id;
    final fareCtrl = TextEditingController(text: '15');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isBn ? 'ভাড়া নির্ধারণ করুন' : 'Set Pairwise Fare'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: fromStopId,
                    isExpanded: true,
                    items: route.sortedStops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.getName(isBn)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => fromStopId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: toStopId,
                    isExpanded: true,
                    items: route.sortedStops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.getName(isBn)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => toStopId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fareCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isBn ? 'ভাড়া (টাকা)' : 'Fare (BDT)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final amount = double.tryParse(fareCtrl.text.trim());
                if (amount == null || fromStopId == toStopId) return;

                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);

                final newFare = SegmentFare(
                  fromStopId: fromStopId,
                  toStopId: toStopId,
                  fare: amount,
                );

                // Replace if already exists or append
                final updatedFares = route.fares.where((f) => !(f.fromStopId == fromStopId && f.toStopId == toStopId)).toList()..add(newFare);

                await _firestore.collection('travel_local_routes').doc(route.id).update({
                  'fares': updatedFares.map((f) => f.toMap()).toList(),
                });

                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(isBn ? 'ভাড়া সংরক্ষিত হয়েছে' : 'Fare saved successfully')));
              },
              child: Text(isBn ? 'সংরক্ষণ' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFareFromRoute(LocalRoute route, SegmentFare fareItem, bool isBn) async {
    final updatedFares = route.fares.where((f) => !(f.fromStopId == fareItem.fromStopId && f.toStopId == fareItem.toStopId)).toList();

    await _firestore.collection('travel_local_routes').doc(route.id).update({
      'fares': updatedFares.map((f) => f.toMap()).toList(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBn ? 'ভাড়া জোড়া মুছে ফেলা হয়েছে' : 'Fare pair removed')));
    }
  }

  // 4. Edit Destination Dialog
  void _showEditDestinationDialog(
    BuildContext context,
    TravelDestination? dest,
    bool isBn,
  ) {
    final nameBnCtrl = TextEditingController(text: dest?.nameBn ?? '');
    final nameEnCtrl = TextEditingController(text: dest?.nameEn ?? '');
    final divisionCtrl = TextEditingController(text: dest?.division ?? 'ঢাকা');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          dest == null
              ? (isBn ? 'নতুন গন্তব্য তৈরি' : 'Add Destination')
              : (isBn ? 'গন্তব্য সম্পাদন' : 'Edit Destination'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameBnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'গন্তব্যের নাম (বাংলা)' : 'Destination (Bangla)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameEnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'গন্তব্যের নাম (ইংরেজি)' : 'Destination (English)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: divisionCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'বিভাগ (Division)' : 'Division',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameBnCtrl.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              final docId = dest?.id ??
                  _firestore.collection('travel_destinations').doc().id;

              final data = {
                'id': docId,
                'nameBn': nameBnCtrl.text.trim(),
                'nameEn': nameEnCtrl.text.trim().isNotEmpty
                    ? nameEnCtrl.text.trim()
                    : nameBnCtrl.text.trim(),
                'normalizedName': nameEnCtrl.text.trim().toLowerCase(),
                'division': divisionCtrl.text.trim(),
                'isPublished': true,
                'isActive': true,
              };

              await _firestore
                  .collection('travel_destinations')
                  .doc(docId)
                  .set(data, SetOptions(merge: true));

              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isBn ? 'গন্তব্য সংরক্ষিত হয়েছে' : 'Destination saved successfully',
                  ),
                ),
              );
            },
            child: Text(
              isBn ? 'সংরক্ষণ' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Edit Operator Dialog
  void _showEditOperatorDialog(
    BuildContext context,
    BusOperator? op,
    bool isBn,
  ) {
    final nameBnCtrl = TextEditingController(text: op?.nameBn ?? '');
    final nameEnCtrl = TextEditingController(text: op?.nameEn ?? '');
    final websiteCtrl = TextEditingController(text: op?.websiteUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          op == null
              ? (isBn ? 'নতুন বাস অপারেটর' : 'Add Bus Operator')
              : (isBn ? 'অপারেটর সম্পাদন' : 'Edit Bus Operator'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameBnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'অপারেটরের নাম (বাংলা)' : 'Operator Name (Bangla)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameEnCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'অপারেটরের নাম (ইংরেজি)' : 'Operator Name (English)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: websiteCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'অফিসিয়াল ওয়েবসাইট' : 'Official Website URL',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameBnCtrl.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              final docId = op?.id ??
                  _firestore.collection('travel_bus_operators').doc().id;

              final data = {
                'id': docId,
                'nameBn': nameBnCtrl.text.trim(),
                'nameEn': nameEnCtrl.text.trim().isNotEmpty
                    ? nameEnCtrl.text.trim()
                    : nameBnCtrl.text.trim(),
                'websiteUrl': websiteCtrl.text.trim(),
                'isPublished': true,
                'isActive': true,
                'counters': op?.counters.map((c) => c.toMap()).toList() ?? [],
              };

              await _firestore
                  .collection('travel_bus_operators')
                  .doc(docId)
                  .set(data, SetOptions(merge: true));

              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isBn ? 'অপারেটর সংরক্ষিত হয়েছে' : 'Operator saved successfully',
                  ),
                ),
              );
            },
            child: Text(
              isBn ? 'সংরক্ষণ' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Edit/Add Counter Dialog for an Operator
  void _showEditCounterDialog(BuildContext context, BusOperator op, BusCounter? counter, bool isBn) {
    final nameCtrl = TextEditingController(text: counter?.name ?? '${op.nameBn} কুষ্টিয়া কাউন্টার');
    final addrBnCtrl = TextEditingController(text: counter?.addressBn ?? 'মজু রোড়, কুষ্টিয়া');
    final addrEnCtrl = TextEditingController(text: counter?.addressEn ?? 'Moju Road, Kushtia');
    final phoneCtrl = TextEditingController(text: counter?.phonePrimary ?? '01711000000');
    final latCtrl = TextEditingController(text: counter?.latitude?.toString() ?? '23.9015');
    final lngCtrl = TextEditingController(text: counter?.longitude?.toString() ?? '89.1205');
    final mapUrlCtrl = TextEditingController(text: counter?.mapUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(counter == null ? (isBn ? 'নতুন কাউন্টার যোগ করুন' : 'Add New Counter') : (isBn ? 'কাউন্টার সম্পাদনা' : 'Edit Counter')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: isBn ? 'কাউন্টারের নাম' : 'Counter Name')),
              const SizedBox(height: 8),
              TextField(controller: addrBnCtrl, decoration: InputDecoration(labelText: isBn ? 'ঠিকানা (বাংলা)' : 'Address (Bangla)')),
              const SizedBox(height: 8),
              TextField(controller: addrEnCtrl, decoration: InputDecoration(labelText: isBn ? 'ঠিকানা (ইংরেজি)' : 'Address (English)')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: isBn ? 'ফোন নম্বর' : 'Phone Number')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'Latitude'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: lngCtrl, decoration: const InputDecoration(labelText: 'Longitude'))),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: mapUrlCtrl,
                decoration: InputDecoration(
                  labelText: isBn ? 'গুগল ম্যাপস লিংক' : 'Google Maps Link',
                  hintText: 'https://maps.app.goo.gl/... বা <iframe src="..."></iframe>',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);

              final updatedCounter = BusCounter(
                id: counter?.id ?? 'counter_${DateTime.now().millisecondsSinceEpoch}',
                operatorId: op.id,
                name: nameCtrl.text.trim(),
                addressBn: addrBnCtrl.text.trim(),
                addressEn: addrEnCtrl.text.trim().isNotEmpty ? addrEnCtrl.text.trim() : addrBnCtrl.text.trim(),
                phonePrimary: phoneCtrl.text.trim(),
                latitude: double.tryParse(latCtrl.text.trim()),
                longitude: double.tryParse(lngCtrl.text.trim()),
                mapUrl: mapUrlCtrl.text.trim().isNotEmpty ? mapUrlCtrl.text.trim() : null,
              );

              final updatedList = counter == null
                  ? (List<BusCounter>.from(op.counters)..add(updatedCounter))
                  : op.counters.map((c) => c.id == counter.id ? updatedCounter : c).toList();

              await _firestore.collection('travel_bus_operators').doc(op.id).update({
                'counters': updatedList.map((c) => c.toMap()).toList(),
              });

              nav.pop();
              messenger.showSnackBar(SnackBar(content: Text(isBn ? 'কাউন্টার সংরক্ষিত হয়েছে' : 'Counter saved successfully')));
            },
            child: Text(isBn ? 'সংরক্ষণ' : 'Save', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCounterFromOperator(BusOperator op, String counterId, bool isBn) async {
    final updatedList = op.counters.where((c) => c.id != counterId).toList();
    await _firestore.collection('travel_bus_operators').doc(op.id).update({
      'counters': updatedList.map((c) => c.toMap()).toList(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBn ? 'কাউন্টার মুছে ফেলা হয়েছে' : 'Counter removed')));
    }
  }

  // 7. Edit Operator-Destination Route Mapping Dialog
  void _showEditOpRouteDialog(BuildContext context, OperatorDestinationRoute? opRoute, bool isBn) {
    final ops = ref.read(busOperatorsProvider).valueOrNull ?? [];
    final dests = ref.read(travelDestinationsProvider).valueOrNull ?? [];

    if (ops.isEmpty || dests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBn ? 'রুট লিংক করার পূর্বে অপারেটর ও গন্তব্য তৈরি করুন' : 'Create operators and destinations first')),
      );
      return;
    }

    String selectedOpId = opRoute?.operatorId ?? ops.first.id;
    String selectedDestId = opRoute?.destinationId ?? dests.first.id;
    final statusCtrl = TextEditingController(text: opRoute?.serviceStatus ?? 'Regular AC & Non-AC');
    final startingCtrl = TextEditingController(text: opRoute?.startingCounterName ?? 'মজু রোড় কাউন্টার');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(opRoute == null ? (isBn ? 'অপারেটর ও গন্তব্য লিংক করুন' : 'Link Operator to Destination') : (isBn ? 'রুট এডিট' : 'Edit Route Link')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedOpId,
                      isExpanded: true,
                      items: ops.map((o) => DropdownMenuItem(value: o.id, child: Text(o.getName(isBn)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedOpId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDestId,
                      isExpanded: true,
                      items: dests.map((d) => DropdownMenuItem(value: d.id, child: Text(d.getName(isBn)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDestId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(controller: statusCtrl, decoration: InputDecoration(labelText: isBn ? 'সার্ভিসের ধরণ (যেমন: AC / Non-AC)' : 'Service Status')),
                const SizedBox(height: 8),
                TextField(controller: startingCtrl, decoration: InputDecoration(labelText: isBn ? 'কুষ্টিয়া যাত্রা পয়েন্ট' : 'Kushtia Departure Point')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'বাতিল' : 'Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final docId = opRoute?.id ?? '${selectedOpId}_$selectedDestId';

                final data = {
                  'id': docId,
                  'operatorId': selectedOpId,
                  'destinationId': selectedDestId,
                  'origin': 'কুষ্টিয়া',
                  'direction': 'bidirectional',
                  'serviceStatus': statusCtrl.text.trim(),
                  'startingCounterName': startingCtrl.text.trim(),
                  'isPublished': true,
                  'isActive': true,
                };

                await _firestore.collection('travel_operator_destinations').doc(docId).set(data, SetOptions(merge: true));

                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(isBn ? 'রুট লিংক সংরক্ষিত হয়েছে' : 'Route link saved successfully')));
              },
              child: Text(isBn ? 'সংরক্ষণ' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
