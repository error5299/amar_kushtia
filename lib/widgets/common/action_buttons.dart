import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CallButton extends StatelessWidget {
  final String? phoneNumber;
  final bool isPrimary;
  final bool compact;

  const CallButton({
    super.key,
    required this.phoneNumber,
    this.isPrimary = true,
    this.compact = false,
  });

  Future<void> _makeCall(BuildContext context) async {
    if (phoneNumber == null || phoneNumber!.isEmpty) return;
    // Extract first phone number if multiple separated by slash or comma
    final rawNumber = phoneNumber!.split(RegExp(r'[/,]')).first.trim();
    final clean = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: clean);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('কল করা সম্ভব হচ্ছে না: $clean')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (phoneNumber == null || phoneNumber!.isEmpty || phoneNumber == '—') {
      return const SizedBox.shrink();
    }

    if (compact) {
      return IconButton.filled(
        onPressed: () => _makeCall(context),
        icon: const Icon(Icons.call_rounded, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
        tooltip: '${l10n.callNow}: $phoneNumber',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _makeCall(context),
      icon: const Icon(Icons.call_rounded, size: 16),
      label: Text(
        l10n.callNow,
        style: AppTypography.labelMedium.copyWith(color: Colors.white, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class DirectionButton extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? directionsUrl;
  final String label;
  final bool compact;

  const DirectionButton({
    super.key,
    required this.latitude,
    required this.longitude,
    this.directionsUrl,
    required this.label,
    this.compact = false,
  });

  Future<void> _openDirections(BuildContext context) async {
    final target = directionsUrl != null && directionsUrl!.isNotEmpty
        ? directionsUrl!
        : (latitude != null && longitude != null
            ? 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude'
            : null);
    if (target == null) return;
    final url = Uri.parse(target);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDirect = directionsUrl != null && directionsUrl!.isNotEmpty;
    if (!hasDirect && (latitude == null || longitude == null || latitude == 0)) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return IconButton.outlined(
        onPressed: () => _openDirections(context),
        icon: const Icon(Icons.directions_rounded, size: 18),
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
        tooltip: l10n.getDirections,
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _openDirections(context),
      icon: const Icon(Icons.directions_rounded, size: 16),
      label: Text(
        l10n.getDirections,
        style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class WebsiteButton extends StatelessWidget {
  final String? url;

  const WebsiteButton({super.key, required this.url});

  Future<void> _openUrl() async {
    if (url == null || url!.isEmpty) return;
    final uri = Uri.parse(url!.startsWith('http') ? url! : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty || url == '—') {
      return const SizedBox.shrink();
    }

    return IconButton.outlined(
      onPressed: _openUrl,
      icon: const Icon(Icons.language_rounded, size: 18),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
      tooltip: url,
    );
  }
}
