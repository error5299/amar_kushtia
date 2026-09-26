import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/app_update_info.dart';
import '../../services/update_service.dart';
import '../../theme/app_typography.dart';

/// Shows an update popup dialog when a newer version is available.
/// If [isMandatory] is true, the dialog cannot be dismissed.
/// Includes support for in-app download progress & open installation.
Future<void> showAppUpdatePopupDialog({
  required BuildContext context,
  required bool isBn,
  required AppUpdateInfo updateInfo,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !updateInfo.isForceUpdate,
    builder: (BuildContext ctx) {
      return PopScope(
        canPop: !updateInfo.isForceUpdate,
        child: AppUpdatePopupDialog(
          isBn: isBn,
          updateInfo: updateInfo,
        ),
      );
    },
  );
}

class AppUpdatePopupDialog extends StatefulWidget {
  final bool isBn;
  final AppUpdateInfo updateInfo;

  const AppUpdatePopupDialog({
    super.key,
    required this.isBn,
    required this.updateInfo,
  });

  @override
  State<AppUpdatePopupDialog> createState() => _AppUpdatePopupDialogState();
}

class _AppUpdatePopupDialogState extends State<AppUpdatePopupDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatusText = '';
  String? _downloadedFilePath;

  Future<void> _handleDownloadAndInstall() async {
    final apkUrl = widget.updateInfo.apkDownloadUrl.trim();
    final playStoreUrl = widget.updateInfo.playStoreUrl.trim();

    // If no direct APK URL is provided or on non-Android platform, launch store/browser URL
    if (apkUrl.isEmpty || !Platform.isAndroid) {
      final target = apkUrl.isNotEmpty ? apkUrl : playStoreUrl;
      if (target.isNotEmpty) {
        final uri = Uri.parse(target);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.05;
      _downloadStatusText = widget.isBn ? 'ডাউনলোড শুরু হচ্ছে...' : 'Starting download...';
    });

    try {
      final uri = Uri.parse(apkUrl);
      final client = http.Client();
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final tempDir = Directory.systemTemp;
        final fileName = 'amar_kushtia_${widget.updateInfo.latestVersion}.apk';
        final file = File('${tempDir.path}/$fileName');
        final sink = file.openWrite();

        await response.stream.listen(
          (chunk) {
            receivedBytes += chunk.length;
            sink.add(chunk);
            if (totalBytes > 0 && mounted) {
              setState(() {
                _downloadProgress = receivedBytes / totalBytes;
                final mbReceived = (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
                final mbTotal = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
                _downloadStatusText = widget.isBn
                    ? 'ডাউনলোড হচ্ছে ($mbReceived MB / $mbTotal MB)...'
                    : 'Downloading ($mbReceived MB / $mbTotal MB)...';
              });
            }
          },
          cancelOnError: true,
        ).asFuture();

        await sink.close();
        client.close();

        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadProgress = 1.0;
            _downloadedFilePath = file.path;
            _downloadStatusText = widget.isBn
                ? 'ডাউনলোড সম্পন্ন! ইনস্টল করুন।'
                : 'Download complete! Tap Install to proceed.';
          });

          // Prompt install / launch installer
          _launchDownloadedApk(file.path);
        }
      } else {
        // Fallback: Launch directly in external browser / downloader
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadStatusText = widget.isBn
              ? 'ডাউনলোড সমস্যা হয়েছে। ব্রাউজারে খোলা হচ্ছে...'
              : 'Download error. Opening browser...';
        });
      }
      // Fallback to browser
      final target = apkUrl.isNotEmpty ? apkUrl : playStoreUrl;
      if (target.isNotEmpty) {
        final u = Uri.parse(target);
        if (await canLaunchUrl(u)) {
          await launchUrl(u, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  Future<void> _launchDownloadedApk(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to APK direct link
        final apkUrl = widget.updateInfo.apkDownloadUrl.trim();
        if (apkUrl.isNotEmpty) {
          await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      final apkUrl = widget.updateInfo.apkDownloadUrl.trim();
      if (apkUrl.isNotEmpty) {
        await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;
    final info = widget.updateInfo;
    final isMandatory = info.isForceUpdate;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 16,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with update illustration icon & version badge
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B5233), Color(0xFF16A34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B5233).withAlpha(45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isBn ? 'নতুন আপডেট উপলব্ধ!' : 'Update Available!',
                              style: const TextStyle(
                                fontFamily: AppTypography.primaryFont,
                                fontSize: 17.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBn
                            ? 'ভার্সন: v${info.latestVersion} • বর্তমান: ${AppVersion.formattedVersionBn}'
                            : 'Version: v${info.latestVersion} • Current: ${AppVersion.formattedVersionEn}',
                        style: TextStyle(
                          fontFamily: AppTypography.primaryFont,
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mandatory Notice alert if force-update
            if (isMandatory)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBn
                            ? 'অ্যাপটি ব্যবহার চালিয়ে যেতে এই আপডেটটি বাধ্যতামূলক।'
                            : 'This update is required to continue using the app.',
                        style: const TextStyle(
                          fontFamily: AppTypography.primaryFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Title & Changelog section
            Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (info.getTitle(isBn).isNotEmpty) ...[
                      Text(
                        info.getTitle(isBn),
                        style: const TextStyle(
                          fontFamily: AppTypography.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      isBn ? 'কী কী নতুন এসেছে:' : 'What\'s new:',
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B5233),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.getNotes(isBn).isNotEmpty
                          ? info.getNotes(isBn)
                          : (isBn
                              ? 'পারফরম্যান্স ও ইউজার অভিজ্ঞতা উন্নত করা হয়েছে।'
                              : 'Performance & stability improvements.'),
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFont,
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Download Progress Bar (When downloading)
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B5233)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 6),
              Text(
                _downloadStatusText,
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFont,
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ] else if (_downloadStatusText.isNotEmpty) ...[
              Text(
                _downloadStatusText,
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFont,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B5233),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isDownloading
                  ? null
                  : (_downloadedFilePath != null
                      ? () => _launchDownloadedApk(_downloadedFilePath!)
                      : _handleDownloadAndInstall),
              icon: Icon(
                _downloadedFilePath != null
                    ? Icons.install_mobile_rounded
                    : Icons.download_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                _downloadedFilePath != null
                    ? (isBn ? 'ইনস্টল করুন (Install)' : 'Install Now')
                    : (isBn ? 'এখনই আপডেট ও ইনস্টল করুন' : 'Update & Install Now'),
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFont,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5233),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),

            if (!isMandatory) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  isBn ? 'পরে মনে করিয়ে দিন' : 'Remind me later',
                  style: TextStyle(
                    fontFamily: AppTypography.primaryFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
