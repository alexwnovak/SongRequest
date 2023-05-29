class SongPoolEntry {
  final String sessionId;
  final int songId;
  final bool wasPlayed;
  final int requests;

  SongPoolEntry({
    required this.sessionId,
    required this.songId,
    required this.wasPlayed,
    required this.requests,
  });

  factory SongPoolEntry.fromMap(Map<String, dynamic> data) {
    return SongPoolEntry(
      sessionId: data['sessionId'],
      songId: data['songId'],
      wasPlayed: data['wasPlayed'] as bool,
      requests: data['requests'] as int,
    );
  }
}
