import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finpilot/shared/models/budget_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _budgetsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Bütçe işlemi için giriş yapınız.');
    }

    return _firestore.collection('users').doc(user.uid).collection('budgets');
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _budgetsCollection.doc(budget.id).set(budget.toMap());
  }

  Stream<List<BudgetModel>> watchBudgets() {
    return _budgetsCollection
        .orderBy('month', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    BudgetModel.fromMap(id: document.id, map: document.data()),
              )
              .toList(),
        );
  }
}
