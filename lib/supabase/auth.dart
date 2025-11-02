import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> sendEmailOtp(String email) async {
  await supabase.auth.signInWithOtp(email: email);
}
