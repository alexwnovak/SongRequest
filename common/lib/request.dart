class Request {
  final String sessionId;
  final int songId;

  Request({
    required this.sessionId,
    required this.songId,
  });

  factory Request.fromMap(Map<String, dynamic> data) {
    return Request(
      sessionId: data['sessionId'],
      songId: data['songId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'songId': songId,
    };
  }

  @override
  String toString() {
    return "$sessionId, $songId";
  }
}
