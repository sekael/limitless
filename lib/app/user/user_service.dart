import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/core/exceptions/unauthenticated_user.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService extends ChangeNotifier {
  UserService({required UserProfileRepository userProfileRepository})
    : _userProfileRepository = userProfileRepository;

  final UserProfileRepository _userProfileRepository;

  UserProfileData? _profileData;
  bool _loadingProfile = false;
  bool _signingOut = false;

  // Getters
  UserProfileData? get profileData => _profileData;
  bool get loadingProfile => _loadingProfile;
  bool get signingOut => _signingOut;
  bool get isLoggedIn {
    try {
      final _ = getCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Initialize after app startup
  Future<void> init() async {
    await refreshProfile();
  }

  // Reload profile of current user from database
  Future<void> refreshProfile() async {
    User user;
    try {
      user = getCurrentUser();
    } on UnauthenticatedUserException catch (e) {
      logger.e(
        'Attempted refreshing profile for a user that is not correctly logged in: ${e.toString()}',
      );
      _profileData = null;
      notifyListeners();
      return;
    }

    _loadingProfile = true;
    notifyListeners();

    try {
      _profileData = await _userProfileRepository.getUserById(user.id);
      logger.i('Successfully retrieved profile data for user ${user.id}');
    } catch (error, stacktrace) {
      logger.e(
        'Failed to load user profile for user ${user.id}',
        error,
        stacktrace,
      );
    } finally {
      _loadingProfile = false;
      notifyListeners();
    }
  }

  // Save profile changes
  Future<void> saveProfileData(
    UserProfileData updatedProfile, {
    bool upsert = false,
  }) async {
    try {
      if (upsert) {
        await _userProfileRepository.upsertMyUser(updatedProfile);
      } else {
        await _userProfileRepository.updateMyUser(updatedProfile);
      }
    } on PostgrestException catch (e) {
      logger.e(
        'Failed to save user profile data because of PostgresException: ${e.message}',
      );
      rethrow;
    } finally {
      _profileData = updatedProfile;
      logger.i('Successfully saved profile data for user ${updatedProfile.id}');
      notifyListeners();
    }
  }

  // Centralized sign-out handler
  Future<void> handleSignOut(BuildContext context) async {
    if (_signingOut) return;

    _signingOut = true;
    notifyListeners();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await signOut();

      // Clear cached profile data
      _profileData = null;
      notifyListeners();
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } on AuthException catch (e, st) {
      logger.e('Authentication error when trying to sign out', e, st);
      if (!context.mounted) return;
      messenger.showSnackBar(
        ErrorSnackbar(
          message: 'An error occurred trying to sign you out',
        ).build(),
      );
    } catch (e, st) {
      logger.e('Unexpected error when trying to sign out', e, st);
      if (!context.mounted) return;
      messenger.showSnackBar(
        ErrorSnackbar(
          message: 'An unexpected error occurred when trying to sign you out',
        ).build(),
      );
    } finally {
      _signingOut = false;
      logger.i('Successfully signed-out user');
      notifyListeners();
    }
  }
}
