import 'package:cloud_firestore/cloud_firestore.dart';

class Gig {
  final String id;
  final String title;
  final DateTime startTime;

  Gig({
    required this.id,
    required this.title,
    required this.startTime,
  });

  factory Gig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Gig(
      id: data?['id'],
      title: data?['title'],
      startTime: (data?['startTime'] as Timestamp).toDate(),
    );
  }
}
