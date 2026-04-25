import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tspendly/main.dart';

class AuthService {
  // ───────────────────────── SIGN UP ─────────────────────────

  /// Register a new user with email & password, then insert a profile row.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? gender,
  }) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    final user = res.user;
    if (user != null) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'displayname': '$firstName $lastName',
        'gender': gender ?? 'male',
      });
    }

    return res;
  }

  // ───────────────────────── SIGN IN ─────────────────────────

  /// Login with email & password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  // ─────────────────────── OTP / MAGIC LINK ──────────────────

  /// Send a magic-link OTP to the given email.
  Future<void> signInWithOtp({required String email}) async {
    await supabase.auth.signInWithOtp(email: email);
  }

  /// Verify an email OTP token.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    final res = await supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
    return res;
  }

  // ─────────────────── FORGOT / RESET PASSWORD ───────────────

  /// Send a password-reset email.
  Future<void> forgotPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  /// Update the password (user must already be authenticated via reset link).
  Future<UserResponse> resetPassword({required String newPassword}) async {
    final res = await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return res;
  }

  // ─────────────────────── GOOGLE SIGN-IN ────────────────────

  /// Native Google Sign-In → exchange ID token with Supabase.
  Future<AuthResponse> signInWithGoogle() async {
    /// TODO: Replace with your actual Web Client ID from Google Cloud Console
    const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

    final googleSignIn = GoogleSignIn(serverClientId: webClientId);

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID token received from Google');
    }

    final res = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return res;
  }

  // ─────────────────────────── SIGN OUT ──────────────────────

  /// Sign the current user out.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ─────────────────────── CURRENT USER ──────────────────────

  /// Returns the currently authenticated user, or null.
  User? get currentUser => supabase.auth.currentUser;
}
