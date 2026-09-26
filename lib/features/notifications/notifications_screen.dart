import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../emergency/emergency_screen.dart';
import '../healthcare/healthcare_screen.dart';
import '../transport/travel_guide_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Icons.emergency_rounded;
      case NotificationType.travel:
        return Icons.directions_bus_rounded;
      case NotificationType.healthcare:
        return Icons.local_hospital_rounded;
      case NotificationType.contentUpdate:
        return Icons.new_releases_rounded;
      case NotificationType.general:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Colors.red;
      case NotificationType.travel:
        return AppColors.primary;
      case NotificationType.healthcare:
        return Colors.blue;
      case NotificationType.contentUpdate:
        return Colors.orange[800]!;
      case NotificationType.general:
        return const Color(0xFF0F766E);
    }
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, AppNotification notif) {
    // Mark as read
    ref.read(readNotificationIdsProvider.notifier).markAsRead(notif.id);

    // Navigate to target route if defined
    if (notif.targetRoute != null) {
      switch (notif.targetRoute) {
        case 'travel_guide':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TravelGuideScreen()));
          break;
        case 'emergency':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
          break;
        case 'healthcare':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthcareScreen()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.isBn;
    final notifsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isBn ? 'নোটিফিকেশন ও নোটিশ' : 'Notifications & Alerts',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          notifsAsync.maybeWhen(
            data: (list) {
              final unreadList = list.where((n) => !n.isRead).toList();
              if (unreadList.isEmpty) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () {
                  ref.read(readNotificationIdsProvider.notifier).markAllAsRead(
                        list.map((n) => n.id).toList(),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBn ? 'সব নোটিফিকেশন পড়া হিসেবে চিহ্নিত হয়েছে' : 'All marked as read',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  isBn ? 'সব পড়া হয়েছে' : 'Mark all read',
                  style: GoogleFonts.googleSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, st) => Center(
          child: Text(isBn ? 'নোটিফিকেশন লোড করতে সমস্যা হয়েছে' : 'Failed to load notifications: $err'),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    isBn ? 'আপাতত কোনো নোটিফিকেশন নেই' : 'No notifications right now',
                    style: GoogleFonts.googleSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            itemCount: notifications.length,
            separatorBuilder: (c, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final typeColor = _getTypeColor(notif.type);
              final typeIcon = _getTypeIcon(notif.type);
              final timeAgo = DateFormat('dd MMM, hh:mm a').format(notif.createdAt);

              return InkWell(
                onTap: () => _handleNotificationTap(context, ref, notif),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notif.isRead
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF86EFAC),
                      width: notif.isRead ? 1 : 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.getTitle(isBn),
                                    style: GoogleFonts.googleSans(
                                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 14.5,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.getBody(isBn),
                              style: GoogleFonts.googleSans(
                                fontSize: 13,
                                color: const Color(0xFF475569),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timeAgo,
                                  style: GoogleFonts.googleSans(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                if (notif.targetRoute != null)
                                  Row(
                                    children: [
                                      Text(
                                        isBn ? 'বিস্তারিত দেখুন' : 'View Details',
                                        style: GoogleFonts.googleSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 11,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
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
}
