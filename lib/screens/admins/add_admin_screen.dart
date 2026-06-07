import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class AddAdminScreen extends ConsumerStatefulWidget {
  const AddAdminScreen({super.key});

  @override
  ConsumerState<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends ConsumerState<AddAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(adminAuthServiceProvider).createAdmin(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            mobile: _mobileCtrl.text,
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            age: int.tryParse(_ageCtrl.text.trim()),
            address: _addressCtrl.text,
          );
      if (!mounted) return;
      _showSnack('Admin created successfully', AppColors.success);
      Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text('Add Admin')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            FxDetailSection(
              title: 'Admin Details',
              children: [
                _field(
                  key: const ValueKey('add-admin-first-name'),
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  validator: _required,
                ),
                _field(
                  key: const ValueKey('add-admin-last-name'),
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.badge_outlined,
                ),
                _field(
                  key: const ValueKey('add-admin-mobile'),
                  controller: _mobileCtrl,
                  label: 'Mobile Number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  ],
                ),
                _field(
                  key: const ValueKey('add-admin-email'),
                  controller: _emailCtrl,
                  label: 'Email ID',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _email,
                ),
                _field(
                  key: const ValueKey('add-admin-age'),
                  controller: _ageCtrl,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _age,
                ),
                _field(
                  key: const ValueKey('add-admin-address'),
                  controller: _addressCtrl,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FxDetailSection(
              title: 'Login',
              children: [
                _field(
                  key: const ValueKey('add-admin-password'),
                  controller: _passwordCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _hidePassword,
                  validator: _password,
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
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const ValueKey('add-admin-submit'),
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
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: Text(_isSaving ? 'Creating...' : 'Create Admin'),
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
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        key: key,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
          suffixIcon: suffixIcon,
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

  String? _password(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Use at least 8 characters';
    return null;
  }
}
