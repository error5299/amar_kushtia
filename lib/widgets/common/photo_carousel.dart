import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/master_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'glass_card.dart';

/// PhotoCarousel renders 1 or multiple high-definition photos in a glassmorphic frame
/// with page indicators, image counter, and tap-to-expand fullscreen lightbox.
class PhotoCarousel extends StatefulWidget {
  final MasterRecord record;
  final double height;
  final Widget? overlayTopRight;

  const PhotoCarousel({
    super.key,
    required this.record,
    this.height = 240,
    this.overlayTopRight,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// Returns curated photos based on record or category so every detail UI has 1+ photos
  List<String> _resolvePhotos() {
    if (widget.record.imageUrls.isNotEmpty) {
      return widget.record.imageUrls;
    }

    final id = widget.record.id;
    final cat = widget.record.categoryId;

    // Curated high-resolution Unsplash/Wikimedia photo sets for prominent Kushtia landmarks
    if (id == 'MD-0041' || id.contains('41') || widget.record.nameEn?.toLowerCase().contains('shilaidaha') == true) {
      // Shilaidaha Kuthibari
      return [
        'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800&q=80',
        'https://images.unsplash.com/photo-1582650625119-3a31f8418b7d?w=800&q=80',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&q=80',
      ];
    } else if (id == 'MD-0042' || id.contains('42') || widget.record.nameEn?.toLowerCase().contains('lalon') == true) {
      // Lalon Shah Mazar
      return [
        'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=800&q=80',
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&q=80',
      ];
    } else if (id == 'MD-0043' || widget.record.nameEn?.toLowerCase().contains('hardinge') == true) {
      // Hardinge Bridge
      return [
        'https://images.unsplash.com/photo-1545156521-77bd85671d30?w=800&q=80',
        'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
      ];
    } else if (cat == 'healthcare') {
      // Hospitals & Healthcare
      return [
        'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&q=80',
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&q=80',
      ];
    } else if (cat == 'police') {
      return [
        'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&q=80',
      ];
    } else if (cat == 'fire') {
      return [
        'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800&q=80',
      ];
    } else if (cat == 'transport') {
      return [
        'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800&q=80',
        'https://images.unsplash.com/photo-1515165562839-978bbcf18277?w=800&q=80',
      ];
    } else if (cat == 'education') {
      return [
        'https://images.unsplash.com/photo-1562774053-701939374585?w=800&q=80',
        'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&q=80',
      ];
    } else if (cat == 'food') {
      return [
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
      ];
    }

    // Default nature / Kushtia aesthetic
    return [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    ];
  }

  void _openFullscreen(BuildContext context, List<String> photos, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImageViewer(
          photos: photos,
          initialIndex: initialIndex,
          title: widget.record.getName(true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = _resolvePhotos();

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // PageView of Photos
            PageView.builder(
              controller: _pageController,
              itemCount: photos.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                final url = photos[index];
                return GestureDetector(
                  onTap: () => _openFullscreen(context, photos, index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: url,
                        httpHeaders: const {
                          'User-Agent':
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 AmarKushtia/1.0',
                        },
                        fit: BoxFit.cover,
                        placeholder: (context, _) => Container(
                          color: AppColors.primaryContainer,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) => Container(
                          color: AppColors.primaryDark,
                          child: Center(
                            child: Icon(
                              widget.record.categoryId == 'tourism'
                                  ? Icons.photo_library_rounded
                                  : Icons.image_outlined,
                              size: 48,
                              color: Colors.white.withAlpha(150),
                            ),
                          ),
                        ),
                      ),
                      // Soft bottom vignette gradient
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withAlpha(160),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Top Right Overlay (e.g. VerificationBadge)
            if (widget.overlayTopRight != null)
              Positioned(
                top: 12,
                right: 12,
                child: widget.overlayTopRight!,
              ),

            // Bottom Left: Image Counter Badge (e.g. "1 / 3")
            if (photos.length > 1)
              Positioned(
                bottom: 12,
                left: 12,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  borderRadius: 14,
                  backgroundColor: Colors.black.withAlpha(120),
                  borderColor: Colors.white.withAlpha(80),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        '${_currentIndex + 1} / ${photos.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Center: Dots Indicators
            if (photos.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (idx) {
                    final isSelected = idx == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withAlpha(120),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

            // Bottom Right: Tap to expand icon
            Positioned(
              bottom: 12,
              right: 12,
              child: GlassCard(
                padding: const EdgeInsets.all(6),
                borderRadius: 14,
                backgroundColor: Colors.black.withAlpha(120),
                borderColor: Colors.white.withAlpha(80),
                onTap: () => _openFullscreen(context, photos, _currentIndex),
                child: const Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fullscreen image lightbox with interactive zoom and pan
class _FullscreenImageViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String title;

  const _FullscreenImageViewer({
    required this.photos,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: AppTypography.labelMedium.copyWith(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (idx) => setState(() => _currentIndex = idx),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.photos[index],
                httpHeaders: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 AmarKushtia/1.0',
                },
                fit: BoxFit.contain,
                placeholder: (context, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
