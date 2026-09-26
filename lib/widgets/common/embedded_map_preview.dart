import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'glass_card.dart';

/// Embedded authentic Google Maps preview using HTML / WebView.
/// Supports custom Google Maps Embed HTML (<iframe>) or Embed URL provided via Admin,
/// and automatically generates Google's official native embed for coordinates when no custom embed is set.
class EmbeddedMapPreview extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String title;
  final String? address;
  final String? directionsUrl;
  final String? mapEmbedUrl;
  final double height;
  final bool interactive;

  const EmbeddedMapPreview({
    super.key,
    this.latitude,
    this.longitude,
    required this.title,
    this.address,
    this.directionsUrl,
    this.mapEmbedUrl,
    this.height = 220,
    this.interactive = true,
  });

  @override
  State<EmbeddedMapPreview> createState() => _EmbeddedMapPreviewState();
}

class _EmbeddedMapPreviewState extends State<EmbeddedMapPreview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted && (error.isForMainFrame ?? true)) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            // When user taps "View larger map" or an external directions link inside Google Maps
            if (!url.contains('output=embed') && !url.contains('/embed')) {
              _openExternalUrl(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadMapHtml();
  }

  @override
  void didUpdateWidget(covariant EmbeddedMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapEmbedUrl != widget.mapEmbedUrl ||
        oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.title != widget.title) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _loadMapHtml();
    }
  }

  void _loadMapHtml() {
    final html = _buildGoogleMapsHtml();
    _controller.loadHtmlString(html);
  }

  String _buildGoogleMapsHtml() {
    final raw = widget.mapEmbedUrl?.trim();
    String iframeHtml = '';

    if (raw != null && raw.isNotEmpty) {
      if (raw.contains('<iframe')) {
        // Full Google Maps <iframe> HTML provided by Admin
        // Enforce 100% width, 100% height and remove restrictive borders
        iframeHtml = raw
            .replaceAll(RegExp(r'width=["\x27][^"\x27]*["\x27]'), 'width="100%"')
            .replaceAll(RegExp(r'height=["\x27][^"\x27]*["\x27]'), 'height="100%"');
      } else if (raw.startsWith('http://') || raw.startsWith('https://')) {
        // URL provided (either embed URL or regular maps URL)
        var embedUrl = raw;
        if (!embedUrl.contains('/embed') && !embedUrl.contains('output=embed')) {
          if (embedUrl.contains('maps.google.com')) {
            embedUrl = embedUrl.contains('?') ? '$embedUrl&output=embed' : '$embedUrl?output=embed';
          }
        }
        iframeHtml = '''
          <iframe 
            src="$embedUrl" 
            width="100%" 
            height="100%" 
            style="border:0;" 
            allowfullscreen="" 
            loading="lazy" 
            referrerpolicy="no-referrer-when-downgrade">
          </iframe>
        ''';
      }
    }

    // Default: Generate official Google Maps HTML embed with Kushtia coordinates & location title
    if (iframeHtml.isEmpty) {
      final lat = widget.latitude != 0.0 ? widget.latitude : 23.9013;
      final lng = widget.longitude != 0.0 ? widget.longitude : 89.1205;
      final label = widget.title.isNotEmpty ? Uri.encodeComponent(widget.title) : 'Kushtia';
      final embedUrl = 'https://maps.google.com/maps?q=$lat,$lng+($label)&hl=bn&z=15&output=embed';

      iframeHtml = '''
        <iframe 
          src="$embedUrl" 
          width="100%" 
          height="100%" 
          style="border:0;" 
          allowfullscreen="" 
          loading="lazy" 
          referrerpolicy="no-referrer-when-downgrade">
        </iframe>
      ''';
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: #F8FAFC;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .map-wrapper {
      width: 100%;
      height: 100%;
      position: relative;
    }
    iframe {
      width: 100% !important;
      height: 100% !important;
      border: 0 !important;
      display: block;
    }
  </style>
</head>
<body>
  <div class="map-wrapper">
    $iframeHtml
  </div>
</body>
</html>
''';
  }

  Future<void> _openExternalUrl(String urlStr) async {
    final uri = Uri.tryParse(urlStr);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections() async {
    final target = widget.directionsUrl?.isNotEmpty == true
        ? widget.directionsUrl!
        : (widget.mapEmbedUrl?.isNotEmpty == true &&
                !widget.mapEmbedUrl!.contains('<iframe') &&
                widget.mapEmbedUrl!.startsWith('http')
            ? widget.mapEmbedUrl!
            : (widget.latitude != null && widget.longitude != null
                ? 'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}'
                : 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent("${widget.title}, Kushtia")}'));
    await _openExternalUrl(target);
  }

  Future<void> _openInGoogleMaps() async {
    final url = widget.latitude != null && widget.longitude != null
        ? 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent("${widget.title}, Kushtia")}';
    await _openExternalUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ── 1. Google Maps WebView Embed ──
            if (!_hasError)
              Positioned.fill(
                child: WebViewWidget(
                  controller: _controller,
                  gestureRecognizers: widget.interactive
                      ? {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        }
                      : const {},
                ),
              ),

            // ── 2. Error Fallback State ──
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 40, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 8),
                      Text(
                        'গুগল ম্যাপস লোড হতে সমস্যা হয়েছে',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openInGoogleMaps,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('গুগল ম্যাপস অ্যাপে দেখুন'),
                      ),
                    ],
                  ),
                ),
              ),

            // ── 3. Subtle Loading Indicator ──
            if (_isLoading && !_hasError)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withAlpha(200),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'গুগল ম্যাপস লোড হচ্ছে...',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── 4. Top-Left: Branded Google Maps & Coordinate Badge ──
            Positioned(
              top: 10,
              left: 10,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                borderRadius: 20,
                backgroundColor: Colors.white.withAlpha(235),
                borderColor: const Color(0xFFE2E8F0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Google Maps Icon
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEA4335), // Google Red
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'গুগল ম্যাপস',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 5. Top-Right: Open in Google Maps Full Screen Button ──
            Positioned(
              top: 10,
              right: 10,
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 20,
                backgroundColor: Colors.white.withAlpha(235),
                borderColor: const Color(0xFFE2E8F0),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, size: 20, color: Color(0xFF334155)),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _openInGoogleMaps,
                  tooltip: 'গুগল ম্যাপসে বড় করে দেখুন',
                ),
              ),
            ),

            // ── 6. Bottom-Right: Open Navigation / Directions Pill ──
            Positioned(
              bottom: 10,
              right: 10,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                borderRadius: 24,
                backgroundColor: AppColors.primary.withAlpha(240),
                borderColor: Colors.white.withAlpha(140),
                onTap: _openDirections,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'দিকনির্দেশনা',
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
          ],
        ),
      ),
    );
  }
}
