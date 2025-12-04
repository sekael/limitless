import 'package:limitless_flutter/core/exceptions/unauthenticated_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

SupabaseClient getSupabaseClient() {
  return supabase;
}

User getCurrentUser() {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw UnauthenticatedUserException();
  }
  return user;
}

Future<void> sendEmailOtp(String email) async {
  await supabase.auth.signInWithOtp(email: email);
}

Future<void> signOut() async {
  await supabase.auth.signOut(scope: SignOutScope.global);
}
