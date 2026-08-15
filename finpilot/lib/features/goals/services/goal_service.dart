import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finpilot/shared/models/goal_model.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _goalsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Hedef işlemi için giriş yapınız.');
    }

    return _firestore.collection('users').doc(user.uid).collection('goals');
  }

  Future<void> addGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.id).set(goal.toMap());
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  Stream<List<GoalModel>> watchGoals() {
    return _goalsCollection
        .orderBy('targetDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    GoalModel.fromMap(id: document.id, map: document.data()),
              )
              .toList(),
        );
  }
}
