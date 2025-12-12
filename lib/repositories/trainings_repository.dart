import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excercises_tracker/models/training.dart';

class TrainingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Training> _getTrainingsCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('trainings')
        .withConverter<Training>(
      fromFirestore: (snapshot, _) => Training.fromFirestore(snapshot),
      toFirestore: (training, _) => training.toJson(),
    );
  }

  Future<List<Training>> getTrainings() async {
    try {
      final querySnapshot = await _getTrainingsCollection()
          .orderBy('serverTimestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting trainings: $e');
      rethrow;
    }
  }

  Future<void> addTraining(Training training) async {
    try {
      await _getTrainingsCollection().add(training);
    } catch (e) {
      print('Error adding training: $e');
      rethrow;
    }
  }

  Future<void> updateTraining(Training training) async {
    if (training.id == null) {
      throw Exception('Training ID is required for update');
    }
    try {
      await _getTrainingsCollection().doc(training.id).update(training.toJson());
    } catch (e) {
      print('Error updating training: $e');
      rethrow;
    }
  }

  Future<void> deleteTraining(String trainingId) async {
    try {
      await _getTrainingsCollection().doc(trainingId).delete();
    } catch (e) {
      print('Error deleting training: $e');
      rethrow;
    }
  }
}