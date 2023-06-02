import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/song.dart';

class MasterSongList {
  final songs = <Song>[
    Song(artist: 'Alice in Chains', title: 'Down in a Hole', album: 'Dirt', year: 1992),
    Song(artist: 'Alice in Chains', title: 'Got Me Wrong', album: 'Dirt and Sap', year: 1992),
    Song(artist: 'Bush', title: 'Glycerine', album: 'Sixteen Stone', year: 1994),
    Song(artist: 'Oasis', title: 'Wonderwall', album: "(What's the Story) Morning Glory?", year: 1995),
    Song(artist: 'Oasis', title: 'Supersonic', album: 'Definitely Maybe', year: 1994),
    Song(artist: 'Weezer', title: "Say It Ain't So", album: 'Weezer', year: 1994),
  ];

  Future populate() async {
    final allSongs = FirebaseFirestore.instance.collection('all_songs');

    for (final song in songs) {
      await allSongs.add({
        'artist': song.artist,
        'title': song.title,
        'album': song.album,
        'year': song.year,
      });
    }
  }
}
