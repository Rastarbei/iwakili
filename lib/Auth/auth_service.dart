import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // SIGN IN
  Future<void> signInWithEmailPassword(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Login failed");
    }
  }

  // SIGN UP
  Future<void> signUpWithEmailPassword(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Signup failed");
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // CURRENT USER
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}