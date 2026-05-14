import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/main.dart';

/// Centralized authentication service for the spendly application.
/// All Supabase auth operations are encapsulated here to keep
/// the UI layer decoupled from the auth implementation.
class AuthService {
  // ───────────────────────── SIGN UP ─────────────────────────

  /// Register a new user with email & password.

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? gender,
  }) async {
    try {
      final fullName = '$firstName $lastName';

      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = res.user;
      if (user != null && gender != null) {
        await supabase
            .from('users')
            .update({'gender': gender.toLowerCase()})
            .eq('id', user.id);
      }

      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  // ───────────────────────── SIGN IN ─────────────────────────

  /// Login with email & password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  // ─────────────────────── OTP / MAGIC LINK ──────────────────

  /// Send a magic-link OTP to the given email.
  Future<void> signInWithOtp({required String email}) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify an email OTP token.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final res = await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // ─────────────────── FORGOT / RESET PASSWORD ───────────────

  /// Send a password-reset email.
  ///
  /// The [redirectTo] deep link is handled by `DeepLinkService` which
  /// navigates to `/reset-password` on a `passwordRecovery` auth event.
  Future<void> forgotPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'spendly://reset-password',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Update the password (user must already be authenticated via reset link).
  ///
  /// After a successful update, the user is signed out so they can
  /// re-authenticate with the new password.
  Future<UserResponse> resetPassword({required String newPassword}) async {
    try {
      final res = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await supabase.auth.signOut();
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // ─────────────────────── GOOGLE SIGN-IN ────────────────────

  /// Native Google Sign-In → exchange ID token with Supabase.
  // Future<AuthResponse> signInWithGoogle() async {
  //   /// TODO: Replace with your actual Web Client ID from Google Cloud Console
  //   const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  //   final googleSignIn = GoogleSignIn(serverClientId: webClientId);

  //   final googleUser = await googleSignIn.signIn();
  //   if (googleUser == null) {
  //     throw Exception('Google sign-in was cancelled');
  //   }

  //   final googleAuth = await googleUser.authentication;
  //   final idToken = googleAuth.idToken;
  //   final accessToken = googleAuth.accessToken;

  //   if (idToken == null) {
  //     throw Exception('No ID token received from Google');
  //   }

  //   final res = await supabase.auth.signInWithIdToken(
  //     provider: OAuthProvider.google,
  //     idToken: idToken,
  //     accessToken: accessToken,
  //   );

  //   return res;
  // }

  // ─────────────────────────── SIGN OUT ──────────────────────

  /// Sign the current user out and end the session.
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  // ─────────────────────── AUTH STATE ────────────────────────

  /// Returns the currently authenticated [User], or `null`.
  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Returns `true` if there is an active session.
  bool isLoggedIn() => supabase.auth.currentSession != null;
}
