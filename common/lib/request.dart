class Request {
  final String sessionId;
  final String song;

  Request({
    required this.sessionId,
    required this.song,
  });

  factory Request.fromMap(Map<String, dynamic> data) {
    return Request(
      sessionId: data['sessionId'],
      song: data['song'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'song': song,
    };
  }

  @override
  String toString() {
    return "$sessionId, $song";
  }
}
