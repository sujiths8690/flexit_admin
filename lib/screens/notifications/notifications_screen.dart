import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _titleCtrl = TextEditingController(text: 'teX notification');
  final _messageCtrl = TextEditingController();
  List<MobileNotification> _notifications = const [];
  bool _loading = true;
  bool _sending = false;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final notifications =
          await ref.read(adminAuthServiceProvider).fetchMobileNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } catch (error) {
      _showSnack(error.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) {
      _showSnack('Enter a notification message', AppColors.error);
      return;
    }

    setState(() => _sending = true);
    try {
      final notification =
          await ref.read(adminAuthServiceProvider).sendMobileNotification(
                title: _titleCtrl.text,
                message: message,
              );
      if (!mounted) return;
      setState(() {
        _notifications = [notification, ..._notifications];
        _messageCtrl.clear();
      });
      _showSnack('Notification sent to customers', AppColors.success);
    } catch (error) {
      _showSnack(error.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resend(MobileNotification notification) async {
    setState(() => _busyId = notification.id);
    try {
      final resent = await ref
          .read(adminAuthServiceProvider)
          .resendMobileNotification(notification.id);
      if (!mounted) return;
      setState(() {
        _notifications = [
          resent,
          ..._notifications.where((item) => item.id != resent.id),
        ];
      });
      _showSnack('Notification resent', AppColors.success);
    } catch (error) {
      _showSnack(error.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _delete(MobileNotification notification) async {
    setState(() => _busyId = notification.id);
    try {
      await ref
          .read(adminAuthServiceProvider)
          .deleteMobileNotification(notification.id);
      if (!mounted) return;
      setState(() {
        _notifications =
            _notifications.where((item) => item.id != notification.id).toList();
      });
      _showSnack('Notification deleted', AppColors.success);
    } catch (error) {
      _showSnack(error.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            FxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send to customers',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.message_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.notifications_active_rounded),
                      label: const Text('Send Notification'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Sent Notifications',
              trailing: '${_notifications.length}',
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_notifications.isEmpty)
              const FxEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                subtitle: 'Sent customer messages will appear here.',
              )
            else
              ..._notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NotificationTile(
                    notification: notification,
                    busy: _busyId == notification.id,
                    onResend: () => _resend(notification),
                    onDelete: () => _delete(notification),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final MobileNotification notification;
  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.busy,
    required this.onResend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${notification.category} · ${AppUtils.formatDateTime(notification.sentAt)}',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (busy)
            const SizedBox(
              width: 28,
              height: 28,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Resend',
                  onPressed: onResend,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
