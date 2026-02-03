import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateUser(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      // 🔑 NEW GMAIL → CLEAN STATE
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'hasActiveSubscription': false,
        'subscriptionId': null,
        'lockedMobile': null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      // EXISTING USER → DO NOT TOUCH SUBSCRIPTION
      await ref.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

