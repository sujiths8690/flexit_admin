import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppUtils {
  static String formatCurrency(double amount, {String currency = '₹'}) {
    if (amount >= 10000000)
      return '$currency${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)
      return '$currency${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    return '$currency${amount.toStringAsFixed(0)}';
  }

  static String formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String formatDateTime(DateTime dt) {
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${formatDate(dt)} · $time';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'banned':
        return AppColors.error;
      case 'blocked':
        return AppColors.error;
      case 'flagged':
        return AppColors.warning;
      case 'suspended':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'refunded':
        return AppColors.info;
      case 'open':
        return AppColors.error;
      case 'investigating':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'ignored':
        return AppColors.textMuted;
      case 'critical':
        return AppColors.error;
      case 'high':
        return const Color(0xFFFF8C42);
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color statusBg(String status) {
    return statusColor(status).withOpacity(0.12);
  }

  static String planEmoji(String plan) {
    switch (plan) {
      case 'Steel':
      case 'Enterprise':
        return '👑';
      case 'Metal':
      case 'Professional':
        return '⚡';
      case 'Clay':
      case 'Starter':
        return '🌱';
      default:
        return '•';
    }
  }

  static Color planColor(String plan) {
    switch (plan) {
      case 'Steel':
      case 'Enterprise':
        return const Color(0xFFFFB547);
      case 'Metal':
      case 'Professional':
        return AppColors.accent;
      case 'Clay':
      case 'Starter':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData errorTypeIcon(String type) {
    switch (type) {
      case 'crash':
        return Icons.bug_report_rounded;
      case 'network':
        return Icons.wifi_off_rounded;
      case 'auth':
        return Icons.lock_outline_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'hardware':
        return Icons.devices_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  static IconData paymentMethodIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'upi':
        return Icons.qr_code_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}
