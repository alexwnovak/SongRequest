import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String sessionId;
  final String artist;
  final String title;
  final bool wasPlayed;

  Song({
    required this.sessionId,
    required this.artist,
    required this.title,
    required this.wasPlayed,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      sessionId: map['sessionId'],
      artist: map['artist'],
      title: map['title'],
      wasPlayed: map['wasPlayed'] as bool,
    );
  }

  factory Song.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Song(
      sessionId: data?['sessionId'],
      artist: data?['artist'],
      title: data?['title'],
      wasPlayed: data?['wasPlayed'] as bool,
    );
  }
}
