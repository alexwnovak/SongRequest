class Request {
  final String sessionId;
  final String title;

  Request({
    required this.sessionId,
    required this.title,
  });

  factory Request.fromMap(Map<String, dynamic> data) {
    return Request(
      sessionId: data['sessionId'],
      title: data['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'title': title,
    };
  }

  @override
  String toString() {
    return "$sessionId, $title";
  }
}
