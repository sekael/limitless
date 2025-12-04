import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/forms/date_picker.dart';
import 'package:limitless_flutter/components/forms/name_form_field.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/form_selection.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
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

  late final UserService _userService;
  bool _loadedProfileData = false;

  @override
  void initState() {
    super.initState();

    _userService = context.read<UserService>();

    _usernameCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileDataIntoForm();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileDataIntoForm() async {
    if (_loadedProfileData) return;
    await _userService.refreshProfile();
    _loadedProfileData = true;

    final u = _userService.profileData;
    if (!mounted || u == null) {
      return;
    }

    setState(() {
      _usernameCtrl.text = u.username ?? '';
      _firstNameCtrl.text = u.firstName ?? '';
      _lastNameCtrl.text = u.lastName ?? '';
      _dob = u.dateOfBirth;
      _countryCode = u.country;

      if (_countryCode != null) {
        final country = Country.tryParse(_countryCode!);
        _countryName = country?.name;
      }
    });
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
      await _userService.saveProfileData(updatedUser, upsert: true);

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

  Widget _countrySelection() {
    final textColor = Theme.of(context).colorScheme.inverseSurface;

    return FormField(
      validator: (value) =>
          (_countryCode == null) ? 'Country of residence is required' : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return InkWell(
          onTap: _submitting
              ? null
              : () {
                  showCountryPicker(
                    context: context,
                    countryListTheme: CountryListThemeData(
                      textStyle: TextStyle(color: textColor),
                      borderRadius: BorderRadius.circular(8.0),
                      flagSize: 12.0,
                      searchTextStyle: TextStyle(color: textColor),
                    ),
                    onSelect: (Country country) {
                      setState(() {
                        _countryCode = country.countryCode;
                        _countryName = country.name;
                      });
                      field.didChange(_countryCode);
                    },
                  );
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Country of Residence',
              border: OutlineInputBorder(),
              errorText: field.errorText,
            ),
            child: FormSelectionText(
              inputText: _countryName,
              hintText: 'Select your country of residence',
            ),
          ),
        );
      },
    );
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
                          'We would like to get to know you a little bit!\nPlease fill out the following fields.',
                    ),
                    const SizedBox(height: 20),
                    NameFormField(
                      controller: _firstNameCtrl,
                      labelText: 'First Name',
                    ),
                    const SizedBox(height: 16),
                    NameFormField(
                      controller: _lastNameCtrl,
                      labelText: 'Last Name',
                    ),
                    const SizedBox(height: 16),
                    NameFormField(
                      controller: _usernameCtrl,
                      labelText: 'Username',
                    ),
                    const SizedBox(height: 16),
                    DatePicker(
                      currentDate: _dob,
                      emptyValidationText: 'Date of birth is required',
                      incompleteValidationText:
                          'Please complete all date fields',
                      onDateChanged: (date) {
                        _dob = date;
                      },
                    ),
                    const SizedBox(height: 16),
                    _countrySelection(),
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
                          onPressed: () async {
                            _submitting
                                ? null
                                : userService.handleSignOut(context);
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
