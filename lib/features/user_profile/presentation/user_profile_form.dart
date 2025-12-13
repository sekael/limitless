import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/forms/date_picker.dart';
import 'package:limitless_flutter/components/forms/name_form_field.dart';
import 'package:limitless_flutter/components/forms/validators.dart';
import 'package:limitless_flutter/components/text/form_selection.dart';

class UserProfileForm extends StatelessWidget {
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
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController usernameCtrl;

  final DateTime? dob;
  final ValueChanged<DateTime?> onDobChanged;

  final String? countryCode;
  final String? countryName;
  final ValueChanged<Country> onCountrySelected;

  String? firstLastNameValidator(String? inputText, String fieldName) {
    final value = inputText?.trim() ?? '';
    if (value.isEmpty) {
      return "$fieldName is required";
    }
    if (value.length > 50) {
      return '$fieldName must be at most 50 characters long';
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
    if (value.length < 6) {
      return 'Username must be at least 6 characters long';
    }
    if (!value.containsOnlyValidCharacters) {
      return 'Allowed are letters, numbers, dashes';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.inverseSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NameFormField(
          controller: firstNameCtrl,
          labelText: 'First Name',
          validatorOverride: (value) =>
              firstLastNameValidator(value, "First Name"),
        ),
        const SizedBox(height: 16),
        NameFormField(
          controller: lastNameCtrl,
          labelText: 'Last Name',
          validatorOverride: (value) =>
              firstLastNameValidator(value, "Last Name"),
        ),
        const SizedBox(height: 16),
        NameFormField(
          controller: usernameCtrl,
          labelText: 'Username',
          validatorOverride: (value) => usernameValidator(value),
        ),
        const SizedBox(height: 16),
        DatePicker(
          currentDate: dob,
          emptyValidationText: 'Date of birth is required',
          incompleteValidationText: 'Please complete all date fields',
          onDateChanged: onDobChanged,
        ),
        const SizedBox(height: 16),
        FormField(
          validator: (value) =>
              (countryCode == null) ? 'Country of residence is required' : null,
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
                    onCountrySelected(country);
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
                  inputText: countryName,
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
