import 'package:flutter/foundation.dart';
import 'package:flutter_application_jin/service/google_signin_exception.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In Service - Minimal & Clean Implementation
class GoogleSignInService {
  static GoogleSignInService? _instance;
  static GoogleSignInService get instance => _instance ??= GoogleSignInService._();
  GoogleSignInService._();

  GoogleSignIn? _googleSignIn;
  bool _isInitialized = false;
  
  static const String _clientId = '135937301382-cd3oq7pvgqt6vm5pk6f3ri3b8akph6oa.apps.googleusercontent.com';
  static const List<String> _scopes = ['email', 'profile', 'openid'];
  
  /// Initialize Google Sign In
  void initialize() {
    if (_isInitialized) return;

    _googleSignIn = GoogleSignIn(
      clientId: _clientId,
      scopes: _scopes,
      // serverClientId only for mobile (web doesn't support it)
      serverClientId: kIsWeb ? null : _clientId,
    );
    
    _isInitialized = true;
    print('✅ GoogleSignIn initialized for ${kIsWeb ? 'Web' : 'Mobile'}');
  }

  /// Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      // Ensure initialized
      if (!_isInitialized) initialize();

      // Sign in
      final GoogleSignInAccount? account = await _googleSignIn!.signIn();
      if (account == null) return null; // User cancelled

      // Get authentication
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Get token (prefer ID token)
      final String? token = auth.idToken ?? auth.accessToken;
      
      if (token == null) {
        throw const GoogleSignInException('No authentication token received');
      }

      print('✅ Google Sign-In successful: ${account.email}');
      return token;

    } catch (error) {
      print('❌ Google Sign-In error: $error');
      throw GoogleSignInErrorHandler.handlePlatformException(error);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!_isInitialized || _googleSignIn == null) return;
    
    try {
      await _googleSignIn!.signOut();
      print('✅ Google sign out successful');
    } catch (error) {
      print('❌ Sign out error: $error');
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    if (!_isInitialized || _googleSignIn == null) return;
    
    try {
      await _googleSignIn!.disconnect();
      print('✅ Google disconnect successful');
    } catch (error) {
      print('❌ Disconnect error: $error');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    if (!_isInitialized || _googleSignIn == null) return false;
    
    try {
      return await _googleSignIn!.isSignedIn();
    } catch (_) {
      return false;
    }
  }

  /// Get current user
  GoogleSignInAccount? get currentUser => _googleSignIn?.currentUser;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
}