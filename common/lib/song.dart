class Song {
  static final Song empty = Song(
    artist: '',
    title: '',
    album: '',
    year: 0,
  )..id = '';

  late final String id;
  final String artist;
  final String title;
  final String album;
  final int year;

  Song({
    required this.artist,
    required this.title,
    required this.album,
    required this.year,
  });

  factory Song.fromMap(Map<String, dynamic> data) {
    return Song(
      artist: data['artist'],
      title: data['title'],
      album: data['album'],
      year: data['year'] as int,
    )..id = data['id'];
  }
}
