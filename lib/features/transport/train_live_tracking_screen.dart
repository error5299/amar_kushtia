import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_typography.dart';

/// Embedded Native-feeling Live Train Tracking Screen
/// Loads https://trainkothai.com/ inside WebViewController with
/// custom UserAgent, DOM Storage, Geolocation & smooth error handling.
/// Also provides a quick one-tap fallback if platform WebView fails.
class TrainLiveTrackingScreen extends StatefulWidget {
  final String? initialTrainName;

  const TrainLiveTrackingScreen({
    super.key,
    this.initialTrainName,
  });

  @override
  State<TrainLiveTrackingScreen> createState() => _TrainLiveTrackingScreenState();
}

class _TrainLiveTrackingScreenState extends State<TrainLiveTrackingScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorDetails = '';

  static const String _liveUrl = 'https://trainkothai.com/';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
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
                _loadingProgress = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Filter out minor resource loading errors (like analytics/ads)
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorDetails = error.description;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_liveUrl));
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(_liveUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.radar_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBn ? 'লাইভ ট্রেন ট্র্যাকিং' : 'Live Train Tracking',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'সরাসরি জিপিএস লোকেশন' : 'Direct Live GPS',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF475569)),
              tooltip: isBn ? 'রিফ্রেশ' : 'Refresh',
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 0;
                });
                _controller.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, size: 21, color: Color(0xFF475569)),
              tooltip: isBn ? 'ব্রাউজারে খুলুন' : 'Open in Browser',
              onPressed: _openExternal,
            ),
            const SizedBox(width: 4),
          ],
          bottom: _loadingProgress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3.0),
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                    minHeight: 3.0,
                  ),
                )
              : null,
        ),
        body: _hasError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Icon(
                          Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                          size: 44,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isBn ? 'লাইভ ট্র্যাকিং পেজ লোড হচ্ছে না' : 'Unable to Load Live Tracking',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBn
                            ? 'ইন্টারনেট সংযোগ চেক করুন অথবা সরাসরি ব্রাউজারে ট্র্যাকিং দেখুন।'
                            : 'Check internet connection or open tracking in browser.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: const Color(0xFF64748B)),
                      ),
                      if (_errorDetails.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorDetails,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _loadingProgress = 0;
                              });
                              _controller.reload();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(isBn ? 'পুনরায় চেষ্টা' : 'Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _openExternal,
                            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                            label: Text(isBn ? 'সরাসরি খুলুন' : 'Open Direct'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
