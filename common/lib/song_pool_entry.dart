import 'package:cloud_firestore/cloud_firestore.dart';

class SongPoolEntry {
  late final String id;
  final String sessionId;
  final String songId;
  final bool wasPlayed;
  final int requests;

  SongPoolEntry({
    required this.sessionId,
    required this.songId,
    required this.wasPlayed,
    required this.requests,
  });

  factory SongPoolEntry.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    return SongPoolEntry(
      sessionId: data['sessionId'],
      songId: data['songId'],
      wasPlayed: data['wasPlayed'] as bool,
      requests: data['requests'] as int,
    )..id = snapshot.id;
  }

  factory SongPoolEntry.fromMap(Map<String, dynamic> data) {
    return SongPoolEntry(
      sessionId: data['sessionId'],
      songId: data['songId'],
      wasPlayed: data['wasPlayed'] as bool,
      requests: data['requests'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'songId': songId,
      'wasPlayed': wasPlayed,
      'requests': requests,
    };
  }
}
