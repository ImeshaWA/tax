//services/firestore_service.dart 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _users = 'users';

  // Save data for a specific tax year in a subcollection
  static Future<void> saveTaxYearData(String taxYear, Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final yearDocId = taxYear.replaceAll('/', '_'); // e.g., '2024_2025'
      await _db
          .collection(_users)
          .doc(uid)
          .collection('taxYears')
          .doc(yearDocId)
          .set(data, SetOptions(merge: true)); // Merge to avoid overwriting fields
    }
  }

  // Get stream for a specific tax year's data
  static Stream<DocumentSnapshot> getTaxYearData(String taxYear) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();
    final yearDocId = taxYear.replaceAll('/', '_');
    return _db.collection(_users).doc(uid).collection('taxYears').doc(yearDocId).snapshots();
  }

  // Save the last selected tax year in the main user document
  static Future<void> saveLastSelectedTaxYear(String taxYear) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection(_users).doc(uid).set({
        'lastSelectedTaxYear': taxYear,
      }, SetOptions(merge: true));
    }
  }

  // Get stream for the user profile (includes lastSelectedTaxYear)
  static Stream<Map<String, dynamic>> getUserProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();
    return _db.collection(_users).doc(uid).snapshots().map((snap) => snap.data() ?? {});
  }

  // Deprecated: Keep for reference, but replace usages with saveTaxYearData
  static Future<void> saveCalculatorData(Map<String, dynamic> data) async {
    // TODO: Remove this method once all calls are updated
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection(_users).doc(uid).set(data, SetOptions(merge: true));
    }
  }

  // Deprecated: Keep for reference, but replace usages with getTaxYearData
  static Stream<DocumentSnapshot> getUserData() {
    // TODO: Remove this method once all calls are updated
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();
    return _db.collection(_users).doc(uid).snapshots();
  }
}