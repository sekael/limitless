import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _table = 'user_profile';

class UserProfileRepositoryAdapter implements UserProfileRepository {
  final SupabaseClient _client = getSupabaseClient();

  @override
  Future<UserProfileData?> getUserById(String userId) async {
    final data = await _client
        .from(_table)
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;

    return UserProfileData.fromMap(data);
  }

  /// Update the current user with new values.
  /// Throws [Exception] if the current user is not authenticated or trying to update a different user.
  /// Throws [PostgresException] if there is an issue updating the user in the database.
  @override
  Future<void> updateMyUser(UserProfileData updatedUser) async {
    User? myUser = getCurrentUser();
    if (myUser == null) {
      logger.e('Current user is not correctly authenticated');
      throw Exception('Current user is not correctly authenticated');
    }

    final userId = myUser.id;
    if (userId != updatedUser.id) {
      logger.e(
        'Current user $userId is not allowed to perform updates for user ${updatedUser.id}',
      );
      throw Exception('Current user is not allowed to perform update');
    }

    await _client.from(_table).update(updatedUser.toMap()).eq('id', userId);
  }

  @override
  Future<void> upsertMyUser(UserProfileData updatedUser) async {
    User? myUser = getCurrentUser();
    if (myUser == null) {
      logger.e('Current user is not correctly authenticated');
      throw Exception('Current user is not correctly authenticated');
    }

    final userId = myUser.id;
    if (userId != updatedUser.id) {
      logger.e(
        'Current user $userId is not allowed to perform updates for user ${updatedUser.id}',
      );
      throw Exception('Current user is not allowed to perform update');
    }
    await _client.from(_table).upsert(updatedUser.toMap());
  }
}
