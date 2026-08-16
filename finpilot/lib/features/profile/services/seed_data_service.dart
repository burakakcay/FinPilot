import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> seedSampleData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Test verilerini yüklemek için giriş yapınız.');
    }

    final jsonText = await rootBundle.loadString('assets/seed_data.json');
    final data = jsonDecode(jsonText) as Map<String, dynamic>;
    final userReference = _firestore.collection('users').doc(user.uid);
    final batch = _firestore.batch();

    _addCollectionToBatch(
      batch: batch,
      userReference: userReference,
      collectionName: 'transactions',
      items: data['transactions'] as List<dynamic>,
      dateField: 'date',
    );

    _addCollectionToBatch(
      batch: batch,
      userReference: userReference,
      collectionName: 'budgets',
      items: data['budgets'] as List<dynamic>,
      dateField: 'month',
    );

    _addCollectionToBatch(
      batch: batch,
      userReference: userReference,
      collectionName: 'goals',
      items: data['goals'] as List<dynamic>,
      dateField: 'targetDate',
    );

    await batch.commit();
  }

  void _addCollectionToBatch({
    required WriteBatch batch,
    required DocumentReference<Map<String, dynamic>> userReference,
    required String collectionName,
    required List<dynamic> items,
    required String dateField,
  }) {
    for (final item in items) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map.remove('id') as String;
      final date = DateTime.parse(map[dateField] as String);

      map[dateField] = Timestamp.fromDate(date);

      final documentReference = userReference
          .collection(collectionName)
          .doc(id);

      batch.set(documentReference, map);
    }
  }
}
