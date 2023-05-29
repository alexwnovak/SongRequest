class Song {
  final int id;
  final String artist;
  final String title;
  final String album;
  final int year;

  Song({
    required this.id,
    required this.artist,
    required this.title,
    required this.album,
    required this.year,
  });

  factory Song.fromMap(Map<String, dynamic> data) {
    return Song(
      id: data['id'] as int,
      artist: data['artist'],
      title: data['title'],
      album: data['album'],
      year: data['year'] as int,
    );
  }
}
