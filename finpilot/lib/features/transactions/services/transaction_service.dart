import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('İşlem kaydetmek için kullanıcı girişi gerekli.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsCollection.doc(transaction.id).set(transaction.toMap());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsCollection.doc(transactionId).delete();
  }

  Stream<List<TransactionModel>> watchTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => TransactionModel.fromMap(
                  id: document.id,
                  map: document.data(),
                ),
              )
              .toList(),
        );
  }
}
