import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:limitless_flutter/features/user_profile/presentation/user_profile_form.dart';
import 'package:provider/provider.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  late UserService userService;
  late UserProfileData currentUser;

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;

  DateTime? _dob;
  String? _countryCode;
  String? _countryName;

  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    userService = context.read<UserService>();
    currentUser = userService.getLoggedInUserProfile();

    _initFromUser(currentUser);
  }

  @override
  void didUpdateWidget(covariant AccountDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent gives us a new user while not editing, refresh fields
    if (currentUser != currentUser && !_isEditing) {
      _initFromUser(currentUser);
    }
  }

  void _initFromUser(UserProfileData user) {
    _firstNameCtrl = TextEditingController(text: user.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: user.lastName ?? '');
    _usernameCtrl = TextEditingController(text: user.username ?? '');

    _dob = user.dateOfBirth;

    final parsed = Country.tryParse(user.country ?? '');
    _countryCode = parsed?.countryCode ?? user.country;
    _countryName = parsed?.name ?? user.country;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Reset fields when leaving edit mode without saving
        _initFromUser(currentUser);
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updatedProfile = UserProfileData(
        id: getCurrentUser().id,
        username: _usernameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        dateOfBirth: _dob,
        country: _countryCode,
      );
      await userService.saveProfileData(updatedProfile);
      if (!mounted) return;
      setState(() => _isEditing = false);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          currentUser = userService.getLoggedInUserProfile();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final country = Country.tryParse(currentUser.country!);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.secondary.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Account Details',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    tooltip: 'Edit profile data',
                    onPressed: _toggleEdit,
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: colorScheme.secondaryContainer
                          .withValues(alpha: 0.7),
                      foregroundColor: colorScheme.onSecondaryContainer,
                    ),
                    icon: Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isEditing) ...[
              _ProfileFieldTile(
                label: 'Username',
                value: currentUser.username!,
              ),
              _ProfileFieldTile(
                label: 'First Name',
                value: currentUser.firstName!,
              ),
              _ProfileFieldTile(
                label: 'Last Name',
                value: currentUser.lastName!,
              ),
              _ProfileFieldTile(
                label: 'Date of Birth',
                value: currentUser.prettyPrintBirthday(),
              ),
              _ProfileFieldTile(
                label: 'Country of Residence',
                value: country == null ? currentUser.country! : country.name,
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: UserProfileForm(
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  usernameCtrl: _usernameCtrl,
                  dob: _dob,
                  onDobChanged: (date) => setState(() => _dob = date),
                  countryCode: _countryCode,
                  countryName: _countryName,
                  onCountrySelected: (c) => {
                    setState(() {
                      _countryCode = c.countryCode;
                      _countryName = c.name;
                    }),
                  },
                  currentUsername: currentUser.username,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : _toggleEdit,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    AdaptiveGlassButton.async(
                      buttonText: 'Save Changes',
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileFieldTile extends StatelessWidget {
  const _ProfileFieldTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
