import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';
import 'edit_admin_screen.dart';

class AdminDetailScreen extends ConsumerStatefulWidget {
  const AdminDetailScreen({super.key, required this.admin});

  final AdminUser admin;

  @override
  ConsumerState<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends ConsumerState<AdminDetailScreen> {
  late AdminUser _admin;
  bool _isLoading = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _admin = widget.admin;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final admin =
          await ref.read(adminAuthServiceProvider).fetchAdminDetails(_admin);
      if (!mounted) return;
      setState(() => _admin = admin);
    } catch (_) {}
  }

  Future<void> _toggleBlock() async {
    final blocked = _admin.isActive;
    final confirmed = await _confirm(
      title: blocked ? 'Block Admin' : 'Unblock Admin',
      message: blocked
          ? 'Block ${_admin.name} from signing in?'
          : 'Allow ${_admin.name} to sign in again?',
      confirmLabel: blocked ? 'Block' : 'Unblock',
      color: blocked ? AppColors.warning : AppColors.success,
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final updated = await ref
          .read(adminAuthServiceProvider)
          .setAdminBlocked(_admin, blocked);
      if (!mounted) return;
      setState(() {
        _admin = updated;
        _changed = true;
      });
      _showSnack(
        blocked ? 'Admin blocked' : 'Admin unblocked',
        blocked ? AppColors.warning : AppColors.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(_cleanError(e), AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editDetails() async {
    final updated = await Navigator.push<AdminUser>(
      context,
      MaterialPageRoute(builder: (_) => EditAdminScreen(admin: _admin)),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _admin = updated;
      _changed = true;
    });
  }

  Future<void> _changePassword() async {
    final password = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PasswordSheet(adminName: _admin.name),
    );
    if (password == null || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final updated =
          await ref.read(adminAuthServiceProvider).changeAdminPassword(
                admin: _admin,
                password: password,
              );
      if (!mounted) return;
      setState(() {
        _admin = updated;
        _changed = true;
      });
      _showSnack('Admin password updated', AppColors.success);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_cleanError(e), AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
      title: 'Delete Admin',
      message: 'Delete ${_admin.name}? This cannot be undone.',
      confirmLabel: 'Delete',
      color: AppColors.error,
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(adminAuthServiceProvider).deleteAdmin(_admin);
      if (!mounted) return;
      _showSnack('Admin deleted', AppColors.success);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_cleanError(e), AppColors.error);
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required Color color,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _admin.isSuperAdmin ? AppColors.warning : AppColors.accent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 230,
              pinned: true,
              actions: [
                if (!_admin.isSuperAdmin)
                  IconButton(
                    onPressed: _isLoading ? null : _editDetails,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (!_admin.isSuperAdmin)
                  IconButton(
                    onPressed: _isLoading ? null : _delete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        isDark ? AppColors.darkBg : AppColors.lightBg,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 64, 20, 28),
                      child: Row(
                        children: [
                          FxAvatar(
                            initials: _initials(_admin),
                            size: 58,
                            color: color,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _admin.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.textPrimary
                                              : AppColors.textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(_admin.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _admin.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                _pill(_admin.role, color),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FxDetailSection(
                    title: 'Contact',
                    children: [
                      InfoRow(label: 'Full Name', value: _admin.name),
                      InfoRow(
                          label: 'First Name',
                          value: _display(_admin.firstName)),
                      InfoRow(
                          label: 'Last Name', value: _display(_admin.lastName)),
                      InfoRow(label: 'Email', value: _admin.email),
                      InfoRow(label: 'Mobile', value: _display(_admin.mobile)),
                      InfoRow(
                        label: 'Age',
                        value: _admin.age == null
                            ? 'Not available'
                            : _admin.age.toString(),
                      ),
                      InfoRow(
                          label: 'Address', value: _display(_admin.address)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FxDetailSection(
                    title: 'Access',
                    children: [
                      InfoRow(label: 'Role', value: _admin.role),
                      InfoRow(label: 'Status', value: _admin.status),
                      InfoRow(
                        label: 'Created By',
                        value: _admin.createdById == null
                            ? 'Not available'
                            : '#${_admin.createdById}',
                      ),
                      InfoRow(
                        label: 'Created At',
                        value: _admin.createdAt == null
                            ? 'Not available'
                            : AppUtils.formatDate(_admin.createdAt!),
                      ),
                      InfoRow(
                        label: 'Last Login',
                        value: _admin.lastLoginAt == null
                            ? 'Not available'
                            : AppUtils.formatDateTime(_admin.lastLoginAt!),
                      ),
                    ],
                  ),
                  if (!_admin.isSuperAdmin) ...[
                    const SizedBox(height: 24),
                    Text(
                      'ACTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textDarkSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: 'Edit Details',
                            icon: Icons.edit_outlined,
                            color: AppColors.info,
                            onTap: _isLoading ? null : _editDetails,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            label: 'Change Password',
                            icon: Icons.lock_reset_rounded,
                            color: AppColors.accent,
                            onTap: _isLoading ? null : _changePassword,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: _admin.isActive ? 'Block Admin' : 'Unblock',
                            icon: _admin.isActive
                                ? Icons.block_rounded
                                : Icons.check_circle_outline_rounded,
                            color: _admin.isActive
                                ? AppColors.warning
                                : AppColors.success,
                            onTap: _isLoading ? null : _toggleBlock,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            label: 'Delete Admin',
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.error,
                            onTap: _isLoading ? null : _delete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _display(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not available' : trimmed;
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

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet({required this.adminName});

  final String adminName;

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set a new password for ${widget.adminName}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _hidePassword,
                validator: _password,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _hideConfirm,
                validator: _confirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _password(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Use at least 8 characters';
    return null;
  }

  String? _confirmPassword(String? value) {
    if (value != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }
}
