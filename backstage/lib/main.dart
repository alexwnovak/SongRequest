import 'package:backstage/master_song_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import 'backstage_drawer.dart';
import 'firebase_options.dart';

import 'package:common/data_service.dart';
import 'package:common/gig.dart';
import 'package:common/song.dart';
import 'package:common/song_catalog.dart';
import 'package:common/song_pool_entry.dart';

late SongCatalog songCatalog;
final DataService dataService = DataService();

final getIt = GetIt.instance;

Future populateAllSongs() async {
  final masterSongList = MasterSongList();
  await masterSongList.populate();
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //====================
  // Firestore data
  //====================

  // final masterSongList = MasterSongList();
  // await masterSongList.populate();

  //======================================================
  // Read the master list of all songs
  // We'll use this to relate Firestore IDs to real data
  //======================================================

  final allSongsSnapshot = await FirebaseFirestore.instance.collection('all_songs').get();
  final songList = allSongsSnapshot.docs.map((e) {
    return Song.fromFirestore(e);
  }).toList();
  songCatalog = SongCatalog(songs: songList);
  getIt.registerSingleton(songCatalog, signalsReady: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 187, 239, 74),
          title: const Text('Backstage'),
        ),
        drawer: const BackstageDrawer(),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: dataService.getCurrentSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // This is the waiting phase for the initial "get the current session"
          // call. This shows nothing since this happens pretty fast, while the
          // next one--retrieving the songs--could be longer, so THAT one gets
          // the progress indicator.
          return const SizedBox.shrink();
        } else {
          final snapshotData = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          final gig = Gig.fromMap(snapshotData.data()!);

          if (gig.sessionId.isEmpty) {
            return const Center(
              child: Text('No session in progress'),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('song_pool').where('sessionId', isEqualTo: gig.sessionId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!.docs.map((e) {
                  return SongPoolEntry.fromMap(e.data())..id = e.id;
                }).toList();
                items.sort((a, b) => b.requests.compareTo(a.requests));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        gig.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: ((context, index) {
                        final songPool = items[index];

                        if (songPool.wasPlayed) {
                          return const SizedBox.shrink();
                        }

                        final song = songCatalog.getById(songPool.songId);

                        return Dismissible(
                          key: Key(song.id),
                          background: Container(
                            alignment: AlignmentDirectional.centerStart,
                            color: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: const Text('mark as played'),
                          ),
                          secondaryBackground: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: const Text('remove from pool'),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              // Swipe to the right marks it as "played"
                              FirebaseFirestore.instance.collection('song_pool').doc(songPool.id).update(
                                {'wasPlayed': true},
                              );
                            } else {
                              // Remove from pool
                              FirebaseFirestore.instance.collection('song_pool').doc(songPool.id).delete();
                            }
                          },
                          child: ListTile(
                            leading: Text(songPool.requests.toString()),
                            title: Text(song.artist),
                            subtitle: Text(song.title),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        }
      },
    );
  }
}
