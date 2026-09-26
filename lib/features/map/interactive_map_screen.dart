import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/seed_master_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/master_record.dart';
import '../../repositories/records_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/templates/tpl02_place_guide.dart';
import '../../widgets/templates/tpl04_service_detail.dart';
import '../../widgets/templates/tpl06_map_marker_card.dart';

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  GoogleMapController? _mapController;
  String _selectedCategory = 'all';
  MasterRecord? _selectedRecord;

  // Kushtia District Central Coordinates
  static const LatLng _kushtiaCenter = LatLng(23.901218, 89.124277);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final recordsAsync = ref.watch(masterRecordsStreamProvider);
    final bedFees = ref.watch(bedFeesProvider).valueOrNull ?? SeedMasterData.bedFees;
    final surgeries = ref.watch(surgerySchedulesProvider).valueOrNull ?? SeedMasterData.surgerySchedules;
    final ambulances = ref.watch(ambulanceModelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMap),
      ),
      body: recordsAsync.when(
        data: (records) {
          // Filter records that have valid coordinates
          var mappedRecords = records.where((r) => r.hasCoordinates).toList();
          if (_selectedCategory != 'all') {
            mappedRecords = mappedRecords
                .where((r) => r.categoryId.toLowerCase() == _selectedCategory.toLowerCase())
                .toList();
          }

          // Build Google Map Markers
          final Set<Marker> markers = mappedRecords.map((r) {
            double hue = BitmapDescriptor.hueGreen;
            if (r.categoryId == 'healthcare') {
              hue = BitmapDescriptor.hueCyan;
            } else if (r.categoryId == 'police') {
              hue = BitmapDescriptor.hueBlue;
            } else if (r.categoryId == 'fire' || r.categoryId == 'emergency') {
              hue = BitmapDescriptor.hueRed;
            } else if (r.categoryId == 'tourism') {
              hue = BitmapDescriptor.hueOrange;
            }

            return Marker(
              markerId: MarkerId(r.id),
              position: LatLng(r.latitude!, r.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              infoWindow: InfoWindow(
                title: r.getName(isBn),
                snippet: r.getAddress(isBn),
              ),
              onTap: () {
                setState(() {
                  _selectedRecord = r;
                });
              },
            );
          }).toSet();

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _kushtiaCenter,
                  zoom: 12,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: (_) {
                  setState(() {
                    _selectedRecord = null;
                  });
                },
              ),

              // Category Filter Chips
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _categoryChip('all', l10n.catAll),
                      _categoryChip('healthcare', l10n.catHealthcare),
                      _categoryChip('police', l10n.catPolice),
                      _categoryChip('fire', l10n.catFire),
                      _categoryChip('tourism', l10n.catTourism),
                      _categoryChip('government', l10n.catGovernment),
                    ],
                  ),
                ),
              ),

              // Selected Marker Detail Preview Card
              if (_selectedRecord != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Tpl06MapMarkerCard(
                    record: _selectedRecord!,
                    onDetailsTap: () {
                      final r = _selectedRecord!;
                      Widget page;
                      if (r.categoryId == 'tourism') {
                        page = Scaffold(
                          appBar: AppBar(title: Text(r.getName(isBn))),
                          body: Tpl02PlaceGuide(record: r),
                        );
                      } else {
                        page = Scaffold(
                          appBar: AppBar(title: Text(r.getName(isBn))),
                          body: Tpl04ServiceDetail(
                            record: r,
                            bedFees: bedFees,
                            surgerySchedules: surgeries,
                            ambulanceModels: ambulances,
                          ),
                        );
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text(l10n.networkError)),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_kushtiaCenter, 13),
          );
        },
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        tooltip: isBn ? 'কুষ্টিয়া কেন্দ্র' : 'Center Kushtia',
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }

  Widget _categoryChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = id;
            _selectedRecord = null;
          });
        },
        selectedColor: AppColors.primaryContainer,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
