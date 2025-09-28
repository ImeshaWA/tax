//services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';

  // Save user calculator data (e.g., income, deductions)
  static Future<void> saveCalculatorData(Map<String, dynamic> data) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection(_usersCollection).doc(uid).set(
      data,
      SetOptions(merge: true),  // Merge with existing data
    );
  }

  // Fetch user data
  static Stream<DocumentSnapshot> getUserData() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();

    return _db.collection(_usersCollection).doc(uid).snapshots();
  }

  // Example: Save tax inputs
  static Future<void> saveTaxInputs({
    required double income,
    required List<String> deductions,
    required DateTime year,
  }) async {
    await saveCalculatorData({
      'income': income,
      'deductions': deductions,
      'year': year.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}