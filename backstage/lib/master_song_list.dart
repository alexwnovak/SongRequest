import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/song.dart';

class MasterSongList {
  final songs = [
    Song(
      title: "Got Me Wrong",
      artist: "Alice in Chains",
      album: "Sap",
      year: 1992,
    ),
    Song(
      title: "Nutshell",
      artist: "Alice in Chains",
      album: "Jar of Flies",
      year: 1994,
    ),
    Song(
      title: "Good",
      artist: "Better Than Ezra",
      album: "Deluxe",
      year: 1993,
    ),
    Song(
      title: "No Rain",
      artist: "Blind Melon",
      album: "Blind Melon",
      year: 1992,
    ),
    Song(
      title: "Glycerine",
      artist: "Bush",
      album: "Sixteen Stone",
      year: 1994,
    ),
    Song(
      title: "Letting the Cables Sleep",
      artist: "Bush",
      album: "The Science of Things",
      year: 1999,
    ),
    Song(
      title: "Wicked Game",
      artist: "Chris Isaak",
      album: "Heart Shaped World",
      year: 1989,
    ),
    Song(
      title: "Sleeping Sickness",
      artist: "City and Colour",
      album: "Bring Me Your Love",
      year: 2008,
    ),
    Song(
      title: "December",
      artist: "Collective Soul",
      album: "Hints, Allegations, and Things Left Unsaid",
      year: 1993,
    ),
    Song(
      title: "Run",
      artist: "Collective Soul",
      album: "Collective Soul",
      year: 1995,
    ),
    Song(
      title: "Low",
      artist: "Cracker",
      album: "Kerosene Hat",
      year: 1993,
    ),
    Song(
      title: "The Man Who Sold The World",
      artist: "David Bowie",
      album: "The Man Who Sold The World",
      year: 1970,
    ),
    Song(
      title: "Santa Monica",
      artist: "Everclear",
      album: "Sparkle and Fade",
      year: 1995,
    ),
    Song(
      title: "Take A Picture",
      artist: "Filter",
      album: "Title of Record",
      year: 1999,
    ),
    Song(
      title: "Big Me",
      artist: "Foo Fighters",
      album: "Foo Fighters",
      year: 1995,
    ),
    Song(
      title: "Everlong",
      artist: "Foo Fighters",
      album: "The Colour and the Shape",
      year: 1997,
    ),
    Song(
      title: "Learn To Fly",
      artist: "Foo Fighters",
      album: "There Is Nothing Left to Lose",
      year: 1999,
    ),
    Song(
      title: "My Hero",
      artist: "Foo Fighters",
      album: "The Colour and the Shape",
      year: 1997,
    ),
    Song(
      title: "Found Out About You",
      artist: "Gin Blossoms",
      album: "New Miserable Experience",
      year: 1992,
    ),
    Song(
      title: "Hey Jealousy",
      artist: "Gin Blossoms",
      album: "New Miserable Experience",
      year: 1992,
    ),
    Song(
      title: "Slide",
      artist: "Goo Goo Dolls",
      album: "Dizzy Up the Girl",
      year: 1998,
    ),
    Song(
      title: "Boulevard of Broken Dreams",
      artist: "Green Day",
      album: "American Idiot",
      year: 2004,
    ),
    Song(
      title: "Brain Stew",
      artist: "Green Day",
      album: "Insomniac",
      year: 1995,
    ),
    Song(
      title: "Good Riddance (Time Of Your Life)",
      artist: "Green Day",
      album: "Nimrod",
      year: 1997,
    ),
    Song(
      title: "Jane Says",
      artist: "Jane's Addiction",
      album: "Nothing's Shocking",
      year: 1988,
    ),
    Song(
      title: "A Talk With George",
      artist: "Jonathan Coulton",
      album: "Thing a Week Two",
      year: 2006,
    ),
    Song(
      title: "Use Somebody",
      artist: "Kings of Leon",
      album: "Only by the Night",
      year: 2008,
    ),
    Song(
      title: "Hallelujah",
      artist: "Leonard Cohen",
      album: "Various Positions",
      year: 1984,
    ),
    Song(
      title: "Lightning Crashes",
      artist: "Live",
      album: "Throwing Copper",
      year: 1994,
    ),
    Song(
      title: "Selling The Drama",
      artist: "Live",
      album: "Throwing Copper",
      year: 1994,
    ),
    Song(
      title: "River Of Deceit",
      artist: "Mad Season",
      album: "Above",
      year: 1995,
    ),
    Song(
      title: "3am",
      artist: "Matchbox Twenty",
      album: "Yourself or Someone Like You",
      year: 1996,
    ),
    Song(
      title: "Crown Of Thorns",
      artist: "Mother Love Bone",
      album: "Apple",
      year: 1990,
    ),
    Song(
      title: "All Apologies",
      artist: "Nirvana",
      album: "In Utero",
      year: 1993,
    ),
    Song(
      title: "Something In The Way",
      artist: "Nirvana",
      album: "Nevermind",
      year: 1991,
    ),
    Song(
      title: "Champagne Supernova",
      artist: "Oasis",
      album: "(What's the Story) Morning Glory?",
      year: 1995,
    ),
    Song(
      title: "Don't Look Back In Anger",
      artist: "Oasis",
      album: "(What's the Story) Morning Glory?",
      year: 1995,
    ),
    Song(
      title: "Hello",
      artist: "Oasis",
      album: "(What's the Story) Morning Glory?",
      year: 1995,
    ),
    Song(
      title: "Supersonic",
      artist: "Oasis",
      album: "Definitely Maybe",
      year: 1994,
    ),
    Song(
      title: "Wonderwall",
      artist: "Oasis",
      album: "(What's the Story) Morning Glory?",
      year: 1995,
    ),
    Song(
      title: "Better Man",
      artist: "Pearl Jam",
      album: "Vitalogy",
      year: 1994,
    ),
    Song(
      title: "Black",
      artist: "Pearl Jam",
      album: "Ten",
      year: 1991,
    ),
    Song(
      title: "Elderly Woman Behind The Counter In A Small Town",
      artist: "Pearl Jam",
      album: "Vs.",
      year: 1993,
    ),
    Song(
      title: "Wish You Were Here",
      artist: "Pink Floyd",
      album: "Wish You Were Here",
      year: 1975,
    ),
  ];

  Future populate() async {
    final allSongs = FirebaseFirestore.instance.collection('all_songs');

    for (final song in songs) {
      print("Adding ${song.artist} - ${song.title}");

      await allSongs.add({
        'artist': song.artist,
        'title': song.title,
        'album': song.album,
        'year': song.year,
      });
    }
  }
}
