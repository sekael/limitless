import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/forms/date_picker.dart';
import 'package:limitless_flutter/components/text/form_selection.dart';
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
  String? _countryCode;
  String? _countryName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    userRepository = UserProfileRepositoryAdapter();
    final u = widget.registeringUser;
    _firstNameCtrl = TextEditingController(text: u.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: u.lastName ?? '');
    _dob = u.dateOfBirth;
    _countryCode = u.country;
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
    widget.registeringUser.country = _countryCode;

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

  Widget _countrySelection() {
    final textColor = Theme.of(context).colorScheme.inverseSurface;

    return FormField(
      validator: (value) =>
          (_countryCode == null) ? 'Country of residence is required' : null,
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
    final t = Theme.of(context).textTheme;

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
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'First name is required'
                          : null,
                      style: t.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Last name is required'
                          : null,
                      style: t.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
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
                          onPressed: _submitting ? null : _handleSignOut,
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
