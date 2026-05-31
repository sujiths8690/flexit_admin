import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';
import 'add_admin_screen.dart';
import 'admin_detail_screen.dart';

class AdminsScreen extends ConsumerStatefulWidget {
  const AdminsScreen({super.key});

  @override
  ConsumerState<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends ConsumerState<AdminsScreen> {
  final _searchCtrl = TextEditingController();
  List<AdminUser> _admins = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);

    try {
      final admins = await ref.read(adminAuthServiceProvider).fetchAdmins(
            search: _searchCtrl.text,
          );
      if (!mounted) return;
      setState(() {
        _admins = admins;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _admins = const [];
        _isLoading = false;
      });
      _showSnack('Failed to load admins', AppColors.error);
    }
  }

  Future<void> _openAddAdmin() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddAdminScreen()),
    );
    if (created == true && mounted) _loadAdmins();
  }

  Future<void> _openAdmin(AdminUser admin) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminDetailScreen(admin: admin)),
    );
    if (changed == true && mounted) _loadAdmins();
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admins'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(74),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FxSearchBar(
              hint: 'Search by name, ID, email, mobile...',
              controller: _searchCtrl,
              onChanged: (_) => _loadAdmins(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAdmin,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _admins.isEmpty
              ? const FxEmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No admins found',
                  subtitle: 'Try adjusting your search',
                )
              : RefreshIndicator(
                  onRefresh: _loadAdmins,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: _admins.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _AdminTile(
                      admin: _admins[i],
                      onTap: () => _openAdmin(_admins[i]),
                    ),
                  ),
                ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.admin,
    required this.onTap,
  });

  final AdminUser admin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = admin.isSuperAdmin ? AppColors.warning : AppColors.accent;

    return FxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          FxAvatar(
            initials: _initials(admin),
            size: 46,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        admin.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(admin.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  admin.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _pill(admin.role, color),
                    const SizedBox(width: 6),
                    if (admin.mobile.isNotEmpty)
                      _pill(admin.mobile, AppColors.info),
                    const Spacer(),
                    Text(
                      '#${admin.id}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _initials(AdminUser admin) {
    final parts = admin.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'AD';
    if (parts.length == 1) {
      final end = parts.first.length < 2 ? parts.first.length : 2;
      return parts.first.substring(0, end).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
