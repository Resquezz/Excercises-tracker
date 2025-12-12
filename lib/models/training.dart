import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excercises_tracker/models/excercise.dart';

class Training {
  final String? id;
  final String date;
  final String type;
  final int duration;
  final String description;
  final List<Exercise> exercises;
  final String? photoUrl;
  final Timestamp? serverTimestamp;

  Training({
    this.id,
    required this.date,
    required this.type,
    required this.duration,
    required this.description,
    required this.exercises,
    this.photoUrl,
    this.serverTimestamp,
  });

  factory Training.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Training(
      id: doc.id,
      date: data['date'] ?? '',
      type: data['type'] ?? '',
      duration: data['duration'] ?? 0,
      description: data['description'] ?? '',
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((e) => Exercise.fromJson(e))
          .toList(),
      photoUrl: data['photoUrl'],
      serverTimestamp: data['serverTimestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'type': type,
      'duration': duration,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'photoUrl': photoUrl,
      'serverTimestamp': serverTimestamp ?? FieldValue.serverTimestamp(),
    };
  }
}