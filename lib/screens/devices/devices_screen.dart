import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/utils/utils.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  List<DeviceInfo> _devices = [];
  List<DeviceInfo> _filtered = [];
  bool _isLoading = true;
  final _filters = ['All', 'Online', 'Offline', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _loadDevices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _devices.where((d) {
        final matchQ = q.isEmpty ||
            d.deviceId.toLowerCase().contains(q) ||
            d.deviceName.toLowerCase().contains(q);
        final matchF = _filter == 'All' ||
            (_filter == 'Online' && d.isOnline) ||
            (_filter == 'Offline' && !d.isOnline) ||
            (_filter == 'Inactive' && !d.isActive);
        return matchQ && matchF;
      }).toList();
    });
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);

    try {
      final devices =
          await ref.read(adminAuthServiceProvider).fetchRegisteredDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _devices = const [];
        _filtered = const [];
        _isLoading = false;
      });
    }
  }

  void _setFilter(String f) {
    setState(() => _filter = f);
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                FxSearchBar(
                    hint: 'Search by device name or ID...',
                    controller: _searchCtrl),
                const SizedBox(height: 10),
                FxFilterChips(
                    options: _filters,
                    selected: _filter,
                    onChanged: _setFilter),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? const FxEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No devices found',
                  subtitle: 'Try adjusting your search or filter',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DeviceTile(
                    device: _filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              DeviceDetailScreen(device: _filtered[i])),
                    ),
                  ),
                ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DeviceInfo device;
  final VoidCallback onTap;

  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = device;
    final statusColor = d.isOnline ? AppColors.success : AppColors.textMuted;

    return FxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tablet_android_rounded,
                size: 24, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(d.deviceName,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textDark),
                          overflow: TextOverflow.ellipsis),
                    ),
                    StatusBadge(d.isOnline ? 'active' : 'offline'),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${d.manufacturer} ${d.model}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _pill(d.deviceId, AppColors.info),
                          _pill(d.ownerName, AppColors.accent),
                        ],
                      ),
                    ),
                    if (d.lastSeen != null) ...[
                      const SizedBox(width: 6),
                      Text(AppUtils.timeAgo(d.lastSeen!),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─── Device Detail Screen ─────────────────────────────────────────────────────

class DeviceDetailScreen extends StatelessWidget {
  final DeviceInfo device;
  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = device;
    final statusColor = d.isOnline ? AppColors.success : AppColors.textMuted;

    return Scaffold(
      appBar: AppBar(title: Text(d.deviceName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.12),
                  statusColor.withOpacity(0.04)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.tablet_android_rounded,
                      size: 32, color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.deviceName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textDark)),
                      const SizedBox(height: 3),
                      Text('${d.manufacturer} ${d.model}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusBadge(d.isOnline ? 'active' : 'offline'),
                          const SizedBox(width: 6),
                          if (!d.isActive) const StatusBadge('inactive'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Battery/Storage Row
          Row(
            children: [
              Expanded(
                  child: _metricCard(
                      'Battery',
                      '${d.batteryLevel}%',
                      _batteryIcon(d.batteryLevel),
                      _batteryColor(d.batteryLevel),
                      isDark)),
              const SizedBox(width: 10),
              Expanded(
                  child: _metricCard(
                      'Storage',
                      '${d.storageUsedGB.toStringAsFixed(1)}/${d.storageTotalGB.toStringAsFixed(0)} GB',
                      Icons.storage_rounded,
                      AppColors.info,
                      isDark)),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Hardware Info',
            children: [
              InfoRow(label: 'Device ID', value: d.deviceId),
              InfoRow(label: 'Serial Number', value: d.serialNumber),
              InfoRow(label: 'MAC Address', value: d.macAddress),
              InfoRow(label: 'Model', value: '${d.manufacturer} ${d.model}'),
              InfoRow(label: 'Firmware', value: d.firmwareVersion),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Software Info',
            children: [
              InfoRow(label: 'OS', value: '${d.osName} ${d.androidVersion}'),
              InfoRow(label: 'App Version', value: d.appVersion),
              InfoRow(label: 'IP Address', value: d.ipAddress),
              InfoRow(label: 'Location', value: d.location),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Ownership',
            children: [
              InfoRow(label: 'Owner', value: d.ownerName),
              InfoRow(label: 'Owner ID', value: d.ownerId),
              InfoRow(label: 'Business', value: d.businessName),
              InfoRow(
                  label: 'Registered',
                  value: AppUtils.formatDate(d.registeredAt)),
              if (d.lastSeen != null)
                InfoRow(
                    label: 'Last Seen',
                    value: AppUtils.formatDateTime(d.lastSeen!)),
            ],
          ),
          if (d.extraDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            FxDetailSection(
              title: 'All Device Info',
              children: d.extraDetails.entries
                  .map((entry) => InfoRow(label: entry.key, value: entry.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level >= 80) return Icons.battery_full_rounded;
    if (level >= 40) return Icons.battery_4_bar_rounded;
    if (level >= 20) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _batteryColor(int level) {
    if (level >= 60) return AppColors.success;
    if (level >= 20) return AppColors.warning;
    return AppColors.error;
  }

  Widget _metricCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
