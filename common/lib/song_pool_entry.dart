class SongPool {
  final String sessionId;
  final int songId;
  final bool wasPlayed;
  final int requests;

  SongPool({
    required this.sessionId,
    required this.songId,
    required this.wasPlayed,
    required this.requests,
  });

  factory SongPool.fromMap(Map<String, dynamic> data) {
    return SongPool(
      sessionId: data['sessionId'],
      songId: data['songId'],
      wasPlayed: data['wasPlayed'] as bool,
      requests: data['requests'] as int,
    );
  }
}
