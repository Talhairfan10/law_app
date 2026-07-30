import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  // ── Google Sign-In ──
  /// Returns the signed-in [User] on success, or null if cancelled.
  /// Throws [FirebaseAuthException] on Firebase errors.
  static Future<User?> signInWithGoogle() async {
    // Trigger the Google Sign-In flow (v7 API: singleton + authenticate)
    // authenticate() throws GoogleSignInException on cancellation
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      // User cancelled or sign-in was interrupted
      debugPrint('DEBUG GOOGLE SIGN-IN: GoogleSignInException: $e');
      return null;
    } catch (e) {
      debugPrint('DEBUG GOOGLE SIGN-IN: Unexpected error during authenticate(): $e');
      debugPrint('DEBUG GOOGLE SIGN-IN: runtimeType=${e.runtimeType}');
      if (e is PlatformException) {
        debugPrint('DEBUG PLATFORM CODE: ${e.code}, DETAILS: ${e.details}, MESSAGE: ${e.message}');
      }
      rethrow;
    }

    // Obtain the auth details from the request
    // In google_sign_in v7, authentication only provides idToken
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    debugPrint('DEBUG GOOGLE SIGN-IN: Got idToken=${googleAuth.idToken != null ? "present (${googleAuth.idToken!.length} chars)" : "NULL"}');

    // Create a new credential (only idToken needed for Firebase)
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      debugPrint('DEBUG GOOGLE SIGN-IN: Firebase signInWithCredential succeeded, uid=${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG GOOGLE SIGN-IN: FirebaseAuthException CODE: ${e.code}, MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('DEBUG GOOGLE SIGN-IN: signInWithCredential error: $e');
      debugPrint('DEBUG GOOGLE SIGN-IN: runtimeType=${e.runtimeType}');
      rethrow;
    }
  }

  // ── Email & Password Sign Up ──
  static Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('DEBUG EMAIL SIGN-UP: Succeeded for uid=${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG EMAIL SIGN-UP: FirebaseAuthException CODE: ${e.code}, MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('DEBUG EMAIL SIGN-UP: Unexpected error: $e');
      rethrow;
    }
  }

  // ── Email & Password Login ──
  static Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('DEBUG EMAIL LOGIN: Succeeded for uid=${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG EMAIL LOGIN: FirebaseAuthException CODE: ${e.code}, MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('DEBUG EMAIL LOGIN: Unexpected error: $e');
      rethrow;
    }
  }


  // ── Link Email/Password to Current User ──
  /// Links an email/password credential to the currently signed-in user.
  /// This allows the user to sign in with either phone OR email/password.
  /// Throws [FirebaseAuthException] on failure.
  static Future<void> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('DEBUG LINK EMAIL: No current user!');
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found. Please sign in again.',
      );
    }
    debugPrint('DEBUG LINK EMAIL: Linking email=$email to uid=${user.uid}');

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {
      await user.linkWithCredential(credential);
      debugPrint('DEBUG LINK EMAIL: linkWithCredential succeeded');
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG LINK EMAIL: FirebaseAuthException CODE: ${e.code}, MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('DEBUG LINK EMAIL: Unexpected error: $e, runtimeType=${e.runtimeType}');
      rethrow;
    }
  }

  // ── Save User Profile to Firestore ──
  /// Writes user profile data to the `users` collection.
  /// Document ID = current user's UID.
  static Future<void> saveUserProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userType,
    required String preferredLanguage,
    String? howDidYouHear,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found. Please sign in again.',
      );
    }
    final uid = user.uid;

    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'preferredLanguage': preferredLanguage,
      'howDidYouHear': howDidYouHear ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'uid': uid,
    });
  }

  // ── Error Message Mapper ──
  /// Maps FirebaseAuthException codes to user-friendly messages.
  static String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'invalid-verification-code':
        return 'Invalid or expired code. Please try again.';
      case 'session-expired':
        return 'The verification code has expired. Please request a new one.';
      case 'email-already-in-use':
        return 'This email address is already registered. Please use a different email or log in.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-credential':
        return 'The provided credential is invalid or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Try signing in with a different method.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'no-current-user':
        return 'No signed-in user found. Please sign in again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }
}
