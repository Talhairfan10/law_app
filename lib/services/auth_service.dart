import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Google Sign-In ──
  /// Returns the signed-in [User] on success, or null if cancelled.
  /// Throws [FirebaseAuthException] on Firebase errors.
  static Future<User?> signInWithGoogle() async {
    // Trigger the Google Sign-In flow (v7 API: singleton + authenticate)
    // authenticate() throws GoogleSignInException on cancellation
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException {
      // User cancelled or sign-in was interrupted
      return null;
    }

    // Obtain the auth details from the request
    // In google_sign_in v7, authentication only provides idToken
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential (only idToken needed for Firebase)
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  // ── Phone Number Verification ──
  /// Initiates phone number verification. [phoneNumber] must be in E.164 format.
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 120),
    );
  }

  // ── OTP Code Verification ──
  /// Verifies the SMS code and signs in. Returns [User] on success.
  /// Throws [FirebaseAuthException] on failure (wrong code, expired, etc.).
  static Future<User?> verifyOtpCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  // ── Auto-verify (Android auto-retrieval) ──
  /// Signs in with a PhoneAuthCredential from auto-retrieval.
  static Future<User?> signInWithPhoneCredential(
      PhoneAuthCredential credential) async {
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential.user;
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
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found. Please sign in again.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.linkWithCredential(credential);
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
