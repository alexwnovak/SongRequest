import 'package:common/song.dart';

class SongCatalog {
  final List<Song> songs;

  SongCatalog({
    required this.songs,
  });

  Song getById(string songId) {
    return songs.firstWhere(
      (element) => element.id == songId,
      orElse: () => Song.empty,
    );
  }
}
