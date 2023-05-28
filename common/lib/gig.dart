import 'package:cloud_firestore/cloud_firestore.dart';

class Gig {
  final String sessionId;
  final String title;
  final DateTime startTime;

  Gig({
    required this.sessionId,
    required this.title,
    required this.startTime,
  });

  factory Gig.fromMap(Map<String, dynamic> data) {
    return Gig(
      sessionId: data['sessionId'],
      title: data['title'],
      startTime: (data['startTime'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return "$sessionId, $title, $startTime";
  }
}
