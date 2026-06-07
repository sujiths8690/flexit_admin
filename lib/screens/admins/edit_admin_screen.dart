import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class EditAdminScreen extends ConsumerStatefulWidget {
  const EditAdminScreen({super.key, required this.admin});

  final AdminUser admin;

  @override
  ConsumerState<EditAdminScreen> createState() => _EditAdminScreenState();
}

class _EditAdminScreenState extends ConsumerState<EditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _addressCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.admin.firstName);
    _lastNameCtrl = TextEditingController(text: widget.admin.lastName);
    _mobileCtrl = TextEditingController(text: widget.admin.mobile);
    _emailCtrl = TextEditingController(text: widget.admin.email);
    _ageCtrl = TextEditingController(text: widget.admin.age?.toString() ?? '');
    _addressCtrl = TextEditingController(text: widget.admin.address);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final admin = await ref.read(adminAuthServiceProvider).updateAdmin(
            admin: widget.admin,
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            mobile: _mobileCtrl.text,
            email: _emailCtrl.text,
            age: int.tryParse(_ageCtrl.text.trim()),
            address: _addressCtrl.text,
          );
      if (!mounted) return;
      _showSnack('Admin details updated', AppColors.success);
      Navigator.pop(context, admin);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_cleanError(e), AppColors.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Admin')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            FxDetailSection(
              title: 'Admin Details',
              children: [
                _field(
                  key: const ValueKey('edit-admin-first-name'),
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  validator: _required,
                ),
                _field(
                  key: const ValueKey('edit-admin-last-name'),
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.badge_outlined,
                ),
                _field(
                  key: const ValueKey('edit-admin-mobile'),
                  controller: _mobileCtrl,
                  label: 'Mobile Number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  ],
                ),
                _field(
                  key: const ValueKey('edit-admin-email'),
                  controller: _emailCtrl,
                  label: 'Email ID',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _email,
                ),
                _field(
                  key: const ValueKey('edit-admin-age'),
                  controller: _ageCtrl,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _age,
                ),
                _field(
                  key: const ValueKey('edit-admin-address'),
                  controller: _addressCtrl,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const ValueKey('edit-admin-submit'),
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.darkBg : Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    Key? key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        key: key,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    final valid = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(text);
    return valid ? null : 'Enter a valid email';
  }

  String? _age(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final age = int.tryParse(text);
    if (age == null || age < 0 || age > 130) return 'Enter a valid age';
    return null;
  }
}
