import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🔥 Use Supabase instead of Firebase
import 'package:i_wakili/screens/signup_screen.dart';
import 'package:i_wakili/screens/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We listen to Supabase's auth state changes
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Check if there is an active session (user is logged in)
          final session = snapshot.data?.session;

          if (session != null) {
            // User is authenticated, take them to the Welcome/Home screen
            return const WelcomeScreen();
          } else {
            // No user found, show the SignUp/Login screen
            return const SignUpScreen();
          }
        },
      ),
    );
  }
}