//services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  static Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.message}');
      rethrow;
    }
  }

  // Login
  static Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}