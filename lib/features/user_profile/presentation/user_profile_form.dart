import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/forms/date_picker.dart';
import 'package:limitless_flutter/components/forms/name_form_field.dart';
import 'package:limitless_flutter/components/forms/validators.dart';
import 'package:limitless_flutter/components/text/form_selection.dart';
import 'package:provider/provider.dart';

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.usernameCtrl,
    required this.dob,
    required this.onDobChanged,
    required this.countryCode,
    required this.countryName,
    required this.onCountrySelected,
    this.currentUsername,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController usernameCtrl;

  final DateTime? dob;
  final ValueChanged<DateTime?> onDobChanged;

  final String? countryCode;
  final String? countryName;
  final ValueChanged<Country> onCountrySelected;

  final String? currentUsername;

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _usernameFieldKey = GlobalKey<FormFieldState>();

  Timer? _debounce;
  String? _asyncUsernameError;

  @override
  void initState() {
    super.initState();
    widget.usernameCtrl.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.usernameCtrl.removeListener(_onUsernameChanged);
    super.dispose();
  }

  void _onUsernameChanged() {
    // Clear error immediately when user types
    if (_asyncUsernameError != null) {
      setState(() => _asyncUsernameError = null);
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final enteredUsername = widget.usernameCtrl.text.trim();

      if (enteredUsername.isEmpty ||
          enteredUsername == widget.currentUsername) {
        return;
      }
      if (enteredUsername.length < 6 ||
          enteredUsername.length > 50 ||
          !enteredUsername.containsOnlyValidCharacters) {
        return;
      }

      final isTaken = await context.read<UserService>().isUsernameTaken(
        enteredUsername,
      );
      if (!mounted) return;

      if (isTaken) {
        setState(() {
          _asyncUsernameError = 'This username is already taken';
        });
        // Trigger the form to visually show the error
        _usernameFieldKey.currentState?.validate();
      }
    });
  }

  String? firstLastNameValidator(String? inputText, String fieldName) {
    final value = inputText?.trim() ?? '';
    if (value.isEmpty) {
      return "$fieldName is required";
    }
    if (value.length > 50) {
      return '$fieldName must be at most 50 characters long';
    }
    if (!value.startsWithUpperCase) {
      return "$fieldName must start with an upper case letter";
    }
    if (!value.isValidName) {
      return "$fieldName must contain only Latin letters";
    }
    return null;
  }

  String? usernameValidator(String? inputText) {
    final value = inputText?.trim() ?? '';
    if (value.isEmpty) {
      return "Username is required";
    }
    if (value.length > 50) {
      return 'Username must be at most 50 characters long';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (!value.containsOnlyValidCharacters) {
      return 'Allowed are letters, numbers, dashes';
    }
    // Synchronous checks passed, return asynchronous check now
    return _asyncUsernameError;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.inverseSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NameFormField(
          controller: widget.firstNameCtrl,
          labelText: 'First Name',
          validatorOverride: (value) =>
              firstLastNameValidator(value, "First Name"),
        ),
        const SizedBox(height: 16),
        NameFormField(
          controller: widget.lastNameCtrl,
          labelText: 'Last Name',
          validatorOverride: (value) =>
              firstLastNameValidator(value, "Last Name"),
        ),
        const SizedBox(height: 16),
        NameFormField(
          controller: widget.usernameCtrl,
          labelText: 'Username',
          validatorOverride: (value) => usernameValidator(value),
        ),
        const SizedBox(height: 16),
        DatePicker(
          currentDate: widget.dob,
          emptyValidationText: 'Date of birth is required',
          incompleteValidationText: 'Please complete all date fields',
          onDateChanged: widget.onDobChanged,
        ),
        const SizedBox(height: 16),
        FormField(
          validator: (value) => (widget.countryCode == null)
              ? 'Country of residence is required'
              : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (field) {
            return InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  countryListTheme: CountryListThemeData(
                    textStyle: TextStyle(color: textColor),
                    borderRadius: BorderRadius.circular(8.0),
                    flagSize: 12.0,
                    searchTextStyle: TextStyle(color: textColor),
                  ),
                  onSelect: (Country country) {
                    widget.onCountrySelected(country);
                    field.didChange(country.countryCode);
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
                  inputText: widget.countryName,
                  hintText: 'Select your country of residence',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
