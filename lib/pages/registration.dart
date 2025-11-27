import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository_adapter.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.registeringUser});

  final UserProfileData registeringUser;

  @override
  State<StatefulWidget> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late final UserProfileRepository userRepository;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  DateTime? _dob;
  String? _country;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    userRepository = UserProfileRepositoryAdapter();
    final u = widget.registeringUser;
    _firstNameCtrl = TextEditingController(text: u.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: u.lastName ?? '');
    _dob = u.dateOfBirth;
    _country = u.country;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    widget.registeringUser.firstName = _firstNameCtrl.text.trim();
    widget.registeringUser.lastName = _lastNameCtrl.text.trim();
    widget.registeringUser.dateOfBirth = _dob;
    widget.registeringUser.country = _country;

    try {
      await userRepository.upsertMyUser(widget.registeringUser);

      if (!mounted) return;
      // Go back through the gate – which will now show Dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // TODO: once available, use global function
  Future<void> _handleSignOut() async {
    try {
      logger.i('Registration: user chose to cancel and sign out');
      await signOut();
      if (!mounted) {
        logger.w('RegistrationPage not mounted after signOut');
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Error trying to log you out: ${e.message}',
        ).build(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Unexpected error during log out').build(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete User Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'First name is required'
                  : null,
            ),
            TextFormField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Last name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _submitting ? null : () => _handleSignOut,
                  child: const Text(
                    'Cancel Registration',
                  ), // TODO: delete user data
                ),
                AdaptiveGlassButton.async(
                  buttonText: 'Complete Registration',
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
