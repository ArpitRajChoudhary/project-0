import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTransaction({
    required String uid,
    required String mobile,
    required String operator,
    required int amount,
  }) async {
    final ref = _firestore.collection('transactions').doc();

    await ref.set({
      'txnId': ref.id,
      'uid': uid,
      'mobile': mobile,
      'operator': operator,
      'amount': amount,
      'status': 'CREATED',
      'paymentOrderId': null,
      'paymentId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }
}

