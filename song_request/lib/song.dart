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
}
