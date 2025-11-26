import 'package:limitless_flutter/features/user_profile/domain/user.dart';

abstract class UserProfileRepository {
  Future<User?> getMyUserById();

  Future<void> updateMyUser(User updatedUser);
}
