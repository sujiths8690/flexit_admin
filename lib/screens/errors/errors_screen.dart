import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/utils/utils.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class ErrorsScreen extends ConsumerStatefulWidget {
  const ErrorsScreen({super.key});

  @override
  ConsumerState<ErrorsScreen> createState() => _ErrorsScreenState();
}

class _ErrorsScreenState extends ConsumerState<ErrorsScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  List<ErrorRecord> _errors = [];
  List<ErrorRecord> _filtered = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  final _filters = ['All', 'Critical', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _loadErrors();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadErrors(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _errors.where((e) {
        final matchQ = q.isEmpty ||
            e.errorId.toLowerCase().contains(q) ||
            e.errorCode.toLowerCase().contains(q) ||
            e.message.toLowerCase().contains(q) ||
            e.ownerId.toLowerCase().contains(q) ||
            e.deviceName.toLowerCase().contains(q) ||
            e.ownerName.toLowerCase().contains(q) ||
            e.businessName.toLowerCase().contains(q);
        final matchF = _filter == 'All' ||
            e.severity.toLowerCase() == _filter.toLowerCase();
        return matchQ && matchF;
      }).toList();
    });
  }

  Future<void> _loadErrors({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final errors = await ref.read(adminAuthServiceProvider).fetchErrors();
      if (!mounted) return;
      setState(() {
        _errors = errors;
        _isLoading = false;
      });
      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      if (showLoading) {
        setState(() {
          _errors = const [];
          _filtered = const [];
          _isLoading = false;
        });
      }
    }
  }

  void _setFilter(String f) {
    setState(() => _filter = f);
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final openCount = _errors.where((e) => e.status == 'open').length;
    final criticalCount = _errors.where((e) => e.severity == 'critical').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Errors'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(118),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                FxSearchBar(
                  hint: 'Search by error ID, error, customer ID, business...',
                  controller: _searchCtrl,
                ),
                const SizedBox(height: 10),
                FxFilterChips(
                  options: _filters,
                  selected: _filter,
                  onChanged: _setFilter,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Bar
          if (openCount > 0 || criticalCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  if (criticalCount > 0)
                    Expanded(
                      child: _summaryBadge(
                        '$criticalCount Critical',
                        Icons.error_rounded,
                        AppColors.error,
                        isDark,
                      ),
                    ),
                  if (criticalCount > 0 && openCount > 0)
                    const SizedBox(width: 10),
                  if (openCount > 0)
                    Expanded(
                      child: _summaryBadge(
                        '$openCount Open',
                        Icons.pending_rounded,
                        AppColors.warning,
                        isDark,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadErrors,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            FxEmptyState(
                              icon: Icons.check_circle_outline_rounded,
                              title: 'No errors found',
                              subtitle: 'Try adjusting your search or filter',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ErrorTile(
                            error: _filtered[i],
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ErrorDetailScreen(error: _filtered[i]),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final ErrorRecord error;
  final bool isDark;
  final VoidCallback onTap;

  const _ErrorTile(
      {required this.error, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = error;
    final severityColor = AppUtils.statusColor(e.severity);

    return FxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(AppUtils.errorTypeIcon(e.errorType),
                    size: 18, color: severityColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.errorCode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textPrimary : AppColors.textDark,
                        letterSpacing: 0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      e.deviceName,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(e.severity),
                  const SizedBox(height: 4),
                  StatusBadge(e.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            e.message,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _pill(e.businessName, AppColors.accent),
                    _pill(e.errorType, AppColors.info),
                  ],
                ),
              ),
              Text(AppUtils.timeAgo(e.timestamp),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─── Error Detail Screen ──────────────────────────────────────────────────────

class ErrorDetailScreen extends StatelessWidget {
  final ErrorRecord error;
  const ErrorDetailScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final e = error;
    final severityColor = AppUtils.statusColor(e.severity);

    return Scaffold(
      appBar: AppBar(title: const Text('Error Detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: severityColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(AppUtils.errorTypeIcon(e.errorType),
                      size: 28, color: severityColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.errorCode,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(e.severity),
                          const SizedBox(width: 6),
                          StatusBadge(e.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(AppUtils.formatDateTime(e.timestamp),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Message
          FxDetailSection(
            title: 'Error Message',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(e.message,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Error Info',
            children: [
              InfoRow(label: 'Error ID', value: e.errorId),
              InfoRow(label: 'Error Code', value: e.errorCode),
              InfoRow(label: 'Type', value: e.errorType.toUpperCase()),
              InfoRow(
                  label: 'Severity',
                  value: '',
                  trailing: StatusBadge(e.severity)),
              InfoRow(
                  label: 'Status', value: '', trailing: StatusBadge(e.status)),
              InfoRow(
                  label: 'Timestamp',
                  value: AppUtils.formatDateTime(e.timestamp)),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Device & Owner',
            children: [
              InfoRow(label: 'Device', value: e.deviceName),
              InfoRow(label: 'Device ID', value: e.deviceId),
              InfoRow(label: 'Owner', value: e.ownerName),
              InfoRow(label: 'Owner ID', value: e.ownerId),
              InfoRow(label: 'Business', value: e.businessName),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Environment',
            children: [
              InfoRow(label: 'App Version', value: e.appVersion),
              InfoRow(label: 'OS Version', value: e.osVersion),
            ],
          ),
          if (e.resolvedAt != null) ...[
            const SizedBox(height: 16),
            FxDetailSection(
              title: 'Resolution',
              children: [
                InfoRow(label: 'Resolved At', value: e.resolvedAt!),
                if (e.resolvedBy != null)
                  InfoRow(label: 'Resolved By', value: e.resolvedBy!),
              ],
            ),
          ],
          if (e.extraDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            FxDetailSection(
              title: 'All Details',
              children: e.extraDetails.entries
                  .map((entry) => InfoRow(label: entry.key, value: entry.value))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          // Stack Trace
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STACK TRACE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textDarkSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  e.stackTrace,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark
                        ? const Color(0xFF79C0FF)
                        : const Color(0xFF0550AE),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action Buttons
          if (e.status == 'open' || e.status == 'investigating')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error marked as ignored'),
                          backgroundColor: AppColors.textMuted,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        size: 16),
                    label: const Text('Ignore'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error marked as resolved'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 16),
                    label: const Text('Mark Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
