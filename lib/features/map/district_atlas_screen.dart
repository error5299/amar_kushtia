import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/glass_card.dart';
import 'interactive_map_screen.dart';

/// Model representing a district or upazila map
class DistrictMapItem {
  final String id;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String pdfUrl;
  final IconData icon;

  const DistrictMapItem({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.pdfUrl,
    this.icon = Icons.map_rounded,
  });
}

/// DistrictAtlasScreen provides an in-app Map & Atlas Hub for Kushtia District & Bangladesh,
/// rendering all 8 official road and boundary maps directly inside the application.
class DistrictAtlasScreen extends StatefulWidget {
  final String? initialUpazilaId;
  const DistrictAtlasScreen({super.key, this.initialUpazilaId});

  @override
  State<DistrictAtlasScreen> createState() => _DistrictAtlasScreenState();
}

class _DistrictAtlasScreenState extends State<DistrictAtlasScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialUpazilaId != null && widget.initialUpazilaId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetId = widget.initialUpazilaId!.toLowerCase();
        final match = _mapItems.firstWhere(
          (m) => m.id.toLowerCase().contains(targetId) || targetId.contains(m.id.toLowerCase()),
          orElse: () => _mapItems.first,
        );
        _openPdfViewer(match);
      });
    }
  }

  static const List<DistrictMapItem> _mapItems = [
    DistrictMapItem(
      id: 'kushtia_full',
      titleBn: 'কুষ্টিয়া জেলা সম্পূর্ণ মানচিত্র',
      titleEn: 'Kushtia Full District Map',
      subtitleBn: 'সম্পূর্ণ জেলা সড়ক ও প্রশাসনিক নেটওয়ার্ক',
      subtitleEn: 'Full District Road & Administrative Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/kushtia.pdf',
      icon: Icons.public_rounded,
    ),
    DistrictMapItem(
      id: 'kushtia_sadar',
      titleBn: 'কুষ্টিয়া সদর উপজেলা মানচিত্র',
      titleEn: 'Kushtia Sadar Upazila Map',
      subtitleBn: 'সদর উপজেলা সড়ক ও যোগাযোগ মানচিত্র',
      subtitleEn: 'Sadar Upazila Road & Transport Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/kushtia-s/kushtia-s_road.pdf',
    ),
    DistrictMapItem(
      id: 'bheramara',
      titleBn: 'ভেড়ামারা উপজেলা মানচিত্র',
      titleEn: 'Bheramara Upazila Map',
      subtitleBn: 'ভেড়ামারা সড়ক ও যোগাযোগ নেটওয়ার্ক',
      subtitleEn: 'Bheramara Road Network Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/bheramara/bheramara_road.pdf',
    ),
    DistrictMapItem(
      id: 'kumarkhali',
      titleBn: 'কুমারখালী উপজেলা মানচিত্র',
      titleEn: 'Kumarkhali Upazila Map',
      subtitleBn: 'কুমারখালী সড়ক ও কুঠিবাড়ি অঞ্চল মানচিত্র',
      subtitleEn: 'Kumarkhali Road & Heritage Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/kumarkhali/kumarkhali_road.pdf',
    ),
    DistrictMapItem(
      id: 'mirpur',
      titleBn: 'মিরপুর উপজেলা মানচিত্র',
      titleEn: 'Mirpur Upazila Map',
      subtitleBn: 'মিরপুর সড়ক ও যোগাযোগ নেটওয়ার্ক',
      subtitleEn: 'Mirpur Road Network Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/mirpur/mirpur_road.pdf',
    ),
    DistrictMapItem(
      id: 'daulatpur',
      titleBn: 'দৌলতপুর উপজেলা মানচিত্র',
      titleEn: 'Daulatpur Upazila Map',
      subtitleBn: 'দৌলতপুর সড়ক ও সীমান্ত যোগাযোগ মানচিত্র',
      subtitleEn: 'Daulatpur Road Network Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/daulatpur/daulatpur_road.pdf',
    ),
    DistrictMapItem(
      id: 'khoksha',
      titleBn: 'খোকসা উপজেলা মানচিত্র',
      titleEn: 'Khoksha Upazila Map',
      subtitleBn: 'খোকসা সড়ক ও যোগাযোগ মানচিত্র',
      subtitleEn: 'Khoksha Road Network Map',
      pdfUrl: 'https://oldweb.lged.gov.bd/UploadedDocument/Map/KHULNA/kushtia/khoksha/khoksha_road.pdf',
    ),
    DistrictMapItem(
      id: 'bangladesh_full',
      titleBn: 'সমগ্র বাংলাদেশ মানচিত্র',
      titleEn: 'Full Bangladesh Map',
      subtitleBn: 'বাংলাদেশ জাতীয় প্রশাসনিক সীমানা ও ভৌগোলিক মানচিত্র',
      subtitleEn: 'Bangladesh National Administrative & Geospatial Map',
      pdfUrl: 'https://www.un.org/geospatial/sites/www.un.org.geospatial/files/files/documents/2020/May/bangladesh_3711_r1_oct03.pdf',
      icon: Icons.language_rounded,
    ),
  ];

  void _openPdfViewer(DistrictMapItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfMapViewerScreen(mapItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'মানচিত্র ও জেলা অ্যাটলাস' : 'Maps & District Atlas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_rounded),
            tooltip: isBn ? 'ইন্টারেক্টিভ মানচিত্র' : 'Interactive Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InteractiveMapScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner Card (Glassmorphic)
            GlassCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: AppColors.primaryContainer.withAlpha(200),
              borderColor: AppColors.primary.withAlpha(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'কুষ্টিয়া জেলা ও বাংলাদেশ মানচিত্র' : 'Kushtia & Bangladesh Atlas',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBn
                                  ? 'অ্যাপের ভেতরেই সরাসরি সম্পূর্ণ মানচিত্র দেখুন ও জুম করুন'
                                  : 'View and zoom complete maps directly inside the app',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InteractiveMapScreen()),
                            );
                          },
                          icon: const Icon(Icons.pin_drop_rounded, size: 18),
                          label: Text(isBn ? 'লাইভ জিপিএস ম্যাপ' : 'Live GPS Map'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Section Title
            Text(
              isBn ? 'মানচিত্র তালিকা' : 'District & Upazila Maps',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              isBn
                  ? 'মানচিত্রের ওপর চাপ দিয়ে অ্যাপের ভেতরেই দেখুন, জুম ইন ও জুম আউট করুন'
                  : 'Tap any map to view and zoom directly inside the app',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            // 3. List of Maps
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mapItems.length,
              separatorBuilder: (context, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _mapItems[index];
                final isHighlight = index == 0 || index == _mapItems.length - 1;

                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isHighlight
                      ? AppColors.primaryContainer.withAlpha(140)
                      : Colors.white.withAlpha(220),
                  borderColor: isHighlight
                      ? AppColors.primary.withAlpha(80)
                      : AppColors.cardBorder,
                  onTap: () => _openPdfViewer(item),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHighlight ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          color: isHighlight ? Colors.white : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? item.titleBn : item.titleEn,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBn ? item.subtitleBn : item.subtitleEn,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// Dedicated in-app PDF Map Viewer Screen
/// Renders the PDF directly inside the app with SfPdfViewer, providing full in-app zoom & pan.
class _PdfMapViewerScreen extends StatefulWidget {
  final DistrictMapItem mapItem;

  const _PdfMapViewerScreen({required this.mapItem});

  @override
  State<_PdfMapViewerScreen> createState() => _PdfMapViewerScreenState();
}

class _PdfMapViewerScreenState extends State<_PdfMapViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.5).clamp(1.0, 5.0);
  }

  void _zoomOut() {
    _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.5).clamp(1.0, 5.0);
  }

  void _resetZoom() {
    _pdfViewerController.zoomLevel = 1.0;
  }

  Future<void> _downloadPdf() async {
    final uri = Uri.parse(widget.mapItem.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text(
          isBn ? widget.mapItem.titleBn : widget.mapItem.titleEn,
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            tooltip: isBn ? 'ছোট করুন' : 'Zoom Out',
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: isBn ? 'আসল আকার' : 'Reset Zoom',
            onPressed: _resetZoom,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            tooltip: isBn ? 'বড় করুন' : 'Zoom In',
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: isBn ? 'ডাউনলোড' : 'Download',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. In-App Direct PDF Viewer
          SfPdfViewer.network(
            widget.mapItem.pdfUrl,
            controller: _pdfViewerController,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
            enableDoubleTapZooming: true,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = null;
                });
              }
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              }
            },
          ),

          // 2. Loading Indicator
          if (_isLoading)
            Center(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isBn ? 'মানচিত্র লোড হচ্ছে...' : 'Loading map...',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Error Fallback
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        isBn ? 'মানচিত্র লোড করা সম্ভব হয়নি' : 'Unable to load map',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBn
                            ? 'নেটওয়ার্ক সংযোগ যাচাই করে পুনরায় চেষ্টা করুন।'
                            : 'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _downloadPdf,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text(isBn ? 'ডাউনলোড' : 'Download'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
