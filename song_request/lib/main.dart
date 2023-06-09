import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:common/song.dart';
import 'package:common/song_catalog.dart';
import 'package:common/song_pool_entry.dart';
import 'package:common/gig.dart';
import 'package:common/data_service.dart';

import 'firebase_options.dart';

late SongCatalog songCatalog;
final DataService dataService = DataService();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final allSongsSnapshot = await FirebaseFirestore.instance.collection('all_songs').get();
  final songList = allSongsSnapshot.docs.map((e) => Song.fromFirestore(e)).toList();
  songCatalog = SongCatalog(songs: songList);

  runApp(const MyApp());
}

class AnimatedListTile extends StatefulWidget {
  final bool canAnimate;
  final bool enabled;
  final Widget title;
  final Widget subtitle;
  final Function() onTap;
  final Function() onCooldownComplete;

  const AnimatedListTile({
    super.key,
    required this.canAnimate,
    required this.enabled,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onCooldownComplete,
  });

  @override
  AnimatedListTileState createState() => AnimatedListTileState();
}

class AnimatedListTileState extends State<AnimatedListTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        widget.onCooldownComplete();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CircularProgressIndicator(
            color: Colors.purple[200],
            value: _progressAnimation.value,
          );
        },
      ),
      enabled: widget.enabled,
      onTap: () => widget.onTap(),
      // onTap: () {
      // if (widget.canAnimate && !_animationController.isAnimating) {
      // _animationController.forward();
      // widget.onTap();
      // }
      // },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request a song!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[200],
          centerTitle: false,
          title: const Text('Pick a song!'),
        ),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasChosen = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: dataService.getCurrentSession(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          final gig = Gig.fromMap(data.data()!);

          if (gig.sessionId.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Ope, catch you next time.'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('song_pool').where('sessionId', isEqualTo: gig.sessionId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!.docs.map((e) {
                  final data = e.data() as Map<String, dynamic>;
                  return SongPoolEntry.fromMap(data)..id = e.id;
                }).toList();

                items.sort((a, b) {
                  final songA = songCatalog.getById(a.songId);
                  final songB = songCatalog.getById(b.songId);
                  final comp = songA.artist.compareTo(songB.artist);

                  if (comp != 0) {
                    // Different values, so return the comparison
                    return comp;
                  } else {
                    // Same value, so SUB-sort it by song title
                    return songA.title.compareTo(songB.title);
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     gig.title,
                    //     style: Theme.of(context).textTheme.headlineLarge,
                    //   ),
                    // ),
                    Expanded(
                      child: MainRegion(
                        songs: items,
                      ),
                      // child: SongList(
                      //   songs: items,
                      // ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('error');
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.green[100],
                  ),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          return const Text('error');
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.green[100],
            ),
          );
        }
      },
    );
  }
}

class MainRegion extends StatefulWidget {
  final List<SongPoolEntry> songs;

  const MainRegion({
    super.key,
    required this.songs,
  });

  @override
  State<MainRegion> createState() => _MainRegionState();
}

class _MainRegionState extends State<MainRegion> {
  late final ConfettiController confetti;
  late bool isConfirmationVisible = false;
  late Song? chosenSong = null;

  @override
  void initState() {
    super.initState();
    confetti = ConfettiController(duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SongList(
          songs: widget.songs,
          songChosen: (song) {
            setState(() {
              chosenSong = song;
              isConfirmationVisible = true;
              Future.delayed(const Duration(seconds: 3)).then(
                (value) => setState(() => isConfirmationVisible = false),
              );
            });
            confetti.stop();
            confetti.play();
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: isConfirmationVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    color: Colors.purple[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Thanks for the request!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (chosenSong != null)
                          Text(
                            "${chosenSong!.artist} - ${chosenSong!.title}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: confetti,
                    numberOfParticles: 50,
                    gravity: 1,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SongList extends StatefulWidget {
  final List<SongPoolEntry> songs;
  final Function(Song) songChosen;

  const SongList({
    super.key,
    required this.songs,
    required this.songChosen,
  });

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  late final List<SongPoolEntry> items;

  bool hasChosen = false;

  // Future reset(SongPoolEntry songPoolEntry) async {
  //   await Future.delayed(const Duration(seconds: 4));
  //   setState(() {
  //     hasChosen = false;
  //     widget.songs.remove(songPoolEntry);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    items = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    // final items = widget.songs;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final songPool = items[index];

        if (songPool.wasPlayed) {
          return const SizedBox.shrink();
        }

        final song = songCatalog.getById(songPool.songId);

        return AnimatedListTile(
          canAnimate: !hasChosen,
          enabled: !hasChosen,
          title: Text(song.artist),
          subtitle: Text(song.title),
          onTap: () async {
            // setState(() => hasChosen = true);
            // reset(songPool);

            final documentId = items[index].id;
            final docRef = FirebaseFirestore.instance.collection('song_pool').doc(documentId);
            await docRef.update(
              {'requests': FieldValue.increment(1)},
            );

            setState(() => items.remove(songPool));
            widget.songChosen(song);
          },
          onCooldownComplete: () {},
        );
      },
    );
  }
}
