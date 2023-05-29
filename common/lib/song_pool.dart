class SongPool {
  final String sessionId;
  final List<int> songIds;

  SongPool({
    required this.sessionId,
    required this.songIds,
  });

  factory SongPool.fromMap(Map<String, dynamic> data) {
    return SongPool(
      sessionId: data['sessionId'],
      songIds: data['songs'].toString().split(',').map((e) => int.parse(e)).toList(),
    );
  }
}
