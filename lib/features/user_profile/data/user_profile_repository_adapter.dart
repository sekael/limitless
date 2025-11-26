import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository.dart';
import 'package:limitless_flutter/features/user_profile/domain/user.dart' as u;
import 'package:supabase_flutter/supabase_flutter.dart';

const _table = 'user_profile';

class UserProfileRepositoryAdapter implements UserProfileRepository {
  final SupabaseClient _client = getSupabaseClient();

  @override
  Future<u.User?> getMyUserById() async {
    User? myUser = getCurrentUser();
    if (myUser == null) {
      logger.e('Current user is not correctly authenticated');
      throw Exception('Current user is not correctly authenticated');
    }

    final String userId = myUser.id;

    final data = await _client
        .from(_table)
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;

    return u.User.fromMap(data);
  }

  /// Update the current user with new values.
  /// Throws [Exception] if the current user is not authenticated or trying to update a different user.
  /// Throws [PostgresException] if there is an issue updating the user in the database.
  @override
  Future<void> updateMyUser(u.User updatedUser) async {
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
}
