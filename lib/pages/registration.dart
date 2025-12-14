import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:limitless_flutter/features/user_profile/presentation/user_profile_form.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;

  DateTime? _dob;
  String? _countryCode;
  String? _countryName;
  bool _submitting = false;
  bool _prefilledFromService = false;

  @override
  void initState() {
    super.initState();

    _usernameCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final profile = context.watch<UserService>().profileData;
    if (!_prefilledFromService && profile != null) {
      _prefilledFromService = true;

      _usernameCtrl.text = profile.username ?? '';
      _firstNameCtrl.text = profile.firstName ?? '';
      _lastNameCtrl.text = profile.lastName ?? '';
      _dob = profile.dateOfBirth;
      _countryCode = profile.country;

      if (_countryCode != null) {
        final country = Country.tryParse(_countryCode!);
        _countryName = country?.name;
      }

      // Set state because we changed non-controller fields
      setState(() {});
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final updatedUser = UserProfileData(
      id: getCurrentUser().id,
      username: _usernameCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      dateOfBirth: _dob,
      country: _countryCode,
    );

    try {
      await context.read<UserService>().saveProfileData(
        updatedUser,
        upsert: true,
      );

      if (!mounted) return;
      // Go back through the gate – which will now show Dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Failed to save profile data because of an unexpected error',
        ).build(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(128),
      appBar: AppBar(
        title: const Text('Complete User Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(32),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CenterAlignedBodyText(
                      bodyText:
                          'Tell us a little something about you!\nPlease fill out the following fields.',
                    ),
                    const SizedBox(height: 20),
                    UserProfileForm(
                      firstNameCtrl: _firstNameCtrl,
                      lastNameCtrl: _lastNameCtrl,
                      usernameCtrl: _usernameCtrl,
                      dob: _dob,
                      onDobChanged: (date) {
                        _dob = date;
                      },
                      countryCode: _countryCode,
                      countryName: _countryName,
                      onCountrySelected: (country) {
                        setState(() {
                          _countryCode = country.countryCode;
                          _countryName = country.name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AdaptiveGlassButton.async(
                          buttonText: 'Complete Registration',
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () async {
                                  userService.handleSignOut(context);
                                },
                          child: const Text('Cancel Registration'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
