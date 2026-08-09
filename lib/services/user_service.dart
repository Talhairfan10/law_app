import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'cloudinary_service.dart';


/// Centralised Firestore/Auth/Storage operations for user profile data.
///
/// All methods are static, matching the pattern used by [AuthService],
/// [CaseService], and [NotificationService].
class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // static final FirebaseStorage _storage = FirebaseStorage.instance;

  static DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  // ─────────────────────────────────────────────────
  //  User Profile — Read
  // ─────────────────────────────────────────────────

  /// Real-time stream of the user's Firestore document.
  static Stream<Map<String, dynamic>> getUserStream(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return <String, dynamic>{};
      return doc.data() as Map<String, dynamic>? ?? {};
    });
  }

  /// One-shot fetch of the user document.
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    final doc = await _userDoc(userId).get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  /// Returns the user's type ('Client' or 'Lawyer').
  /// Returns empty string if the user document doesn't exist.
  static Future<String> getUserType(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists) return '';
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return (data['userType'] as String?) ?? '';
    } catch (e) {
      debugPrint('UserService: Failed to get user type: $e');
      return '';
    }
  }

  // ─────────────────────────────────────────────────
  //  User Profile — Update
  // ─────────────────────────────────────────────────

  /// Updates profile fields (name, email, phone) in Firestore
  /// and syncs displayName to Firebase Auth.
  static Future<void> updateProfile(
    String userId, {
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['fullName'] = fullName;
    if (email != null) updates['email'] = email;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

    if (updates.isNotEmpty) {
      await _userDoc(userId).set(updates, SetOptions(merge: true));
    }

    // Sync displayName to Firebase Auth
    if (fullName != null) {
      await _auth.currentUser?.updateDisplayName(fullName);
    }
  }

  // ─────────────────────────────────────────────────
  //  Profile Photo
  // ─────────────────────────────────────────────────

  /// Uploads a profile photo to Firebase Storage and updates
  /// both Firestore `photoUrl` and Firebase Auth `photoURL`.
  static Future<String?> uploadProfilePhoto(String userId, File file) async {
    /* --- FIREBASE STORAGE UPLOAD (Commented out due to Spark plan limits) ---
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    */

    // --- CLOUDINARY UPLOAD ---
    final response = await CloudinaryService.uploadFile(
      file,
      folder: 'users/$userId',
    );

    if (response == null || !response.containsKey('secure_url')) {
      debugPrint('UserService: Cloudinary upload returned null or missing secure_url');
      return null;
    }

    final downloadUrl = response['secure_url'] as String;

    // Update Firestore
    await _userDoc(userId).set({'photoUrl': downloadUrl}, SetOptions(merge: true));

    // Update Firebase Auth
    await _auth.currentUser?.updatePhotoURL(downloadUrl);

    return downloadUrl;
  }

  // ─────────────────────────────────────────────────
  //  Address
  // ─────────────────────────────────────────────────

  static Future<void> saveAddress(
    String userId, {
    required String street,
    required String city,
    required String province,
    required String postalCode,
  }) async {
    await _userDoc(userId).set({
      'address': {
        'street': street,
        'city': city,
        'province': province,
        'postalCode': postalCode,
      },
    }, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────
  //  Notification Preferences
  // ─────────────────────────────────────────────────

  static Future<void> savePreferences(
    String userId, {
    required bool pushNotifications,
    required bool emailNotifications,
    required bool smsNotifications,
  }) async {
    await _userDoc(userId).set({
      'preferences': {
        'pushNotifications': pushNotifications,
        'emailNotifications': emailNotifications,
        'smsNotifications': smsNotifications,
      },
    }, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────
  //  Language
  // ─────────────────────────────────────────────────

  static Future<void> saveLanguagePreference(
      String userId, String language) async {
    await _userDoc(userId)
        .set({'preferredLanguage': language}, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────
  //  Security — Change Password
  // ─────────────────────────────────────────────────

  /// Re-authenticates and then updates the user's password.
  /// Throws [FirebaseAuthException] on failure.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found. Please sign in again.',
      );
    }

    // Re-authenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
    debugPrint('UserService: Password updated successfully');
  }

  // ─────────────────────────────────────────────────
  //  Payment Methods (subcollection)
  // ─────────────────────────────────────────────────

  static CollectionReference _paymentMethodsRef(String userId) =>
      _userDoc(userId).collection('paymentMethods');

  /// Real-time stream of saved payment methods.
  static Stream<List<Map<String, dynamic>>> getPaymentMethodsStream(
      String userId) {
    return _paymentMethodsRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Adds a new payment method.
  static Future<void> addPaymentMethod(
    String userId, {
    required String methodType, // 'visa', 'mastercard', 'jazzcash', 'easypaisa'
    required String displayName, // e.g. "Visa •••• 1234" or "JazzCash 0312***4567"
    required String holderName,
    String? last4,
    String? phoneNumber,
  }) async {
    await _paymentMethodsRef(userId).add({
      'methodType': methodType,
      'displayName': displayName,
      'holderName': holderName,
      'last4': last4,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a payment method by document ID.
  static Future<void> deletePaymentMethod(
      String userId, String docId) async {
    await _paymentMethodsRef(userId).doc(docId).delete();
  }

  // ─────────────────────────────────────────────────
  //  Messages Count (subcollection)
  // ─────────────────────────────────────────────────

  /// Real-time count of messages for this user.
  static Stream<int> getMessagesCount(String userId) {
    return _userDoc(userId)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ─────────────────────────────────────────────────
  //  Stats — computed from Cases
  // ─────────────────────────────────────────────────

  /// Stream of total documents count across all user's cases.
  static Stream<int> getTotalDocumentsCount(String userId) {
    return _firestore
        .collection('cases')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final docUrls = data['documentUrls'] as List<dynamic>? ?? [];
        total += docUrls.length;
      }
      return total;
    });
  }

  /// Stream of total paid payments (sum of assignedLawyer.fee where feeStatus == 'paid').
  static Stream<double> getTotalPayments(String userId) {
    return _firestore
        .collection('cases')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lawyer = data['assignedLawyer'] as Map<String, dynamic>?;
        if (lawyer != null && lawyer['feeStatus'] == 'paid') {
          total += (lawyer['fee'] as num?)?.toDouble() ?? 0;
        }
      }
      return total;
    });
  }

  /// Stream of case count for this user.
  static Stream<int> getCaseCount(String userId) {
    return _firestore
        .collection('cases')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
