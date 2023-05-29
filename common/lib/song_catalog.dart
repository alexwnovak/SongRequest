import 'package:common/song.dart';

class SongCatalog {
  final List<Song> songs;

  SongCatalog({
    required this.songs,
  });

  Song getById(int songId) {
    return songs.firstWhere((element) => element.id == songId);
  }
}
