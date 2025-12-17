import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';

abstract class UserProfileRepository {
  Future<UserProfileData?> getUserById(String userId);

  Future<void> updateMyUser(UserProfileData updatedUser);

  Future<void> upsertMyUser(UserProfileData updatedUser);

  Future<bool> isUsernameTaken(String username);
}
