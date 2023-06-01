import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/song.dart';

class MasterSongList {
  final songs = <Song>[
    Song(artist: 'Oasis', title: 'Wonderwall', album: "(What's the Story) Morning Glory?", year: 1995),
  ];

  Future clearSongPool() async {
    // FirebaseFirestore.instance.collection('all_songs').snapshots().map()

    // for (final doc in snapshots)

    // for (final song in songs) {}
  }

  Future populate() async {
    final allSongs = FirebaseFirestore.instance.collection('all_songs');

    for (final song in songs) {
      final newDoc = allSongs.doc();
      song.id = newDoc.id;

      newDoc.update({
        'artist': song.artist,
        'title': song.title,
        'album': song.album,
        'year': song.year,
      });
    }
  }
}
