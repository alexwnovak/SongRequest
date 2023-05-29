import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'backstage_drawer.dart';
import 'firebase_options.dart';
import 'package:common/gig.dart';
import 'package:common/request.dart';
import 'package:common/song.dart';
import 'package:common/song_catalog.dart';
import 'package:common/data_service.dart';

late SongCatalog songCatalog;
final DataService dataService = DataService();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final allSongsSnapshot = await FirebaseFirestore.instance.collection('all_songs').get();
  final songList = allSongsSnapshot.docs.map((e) => Song.fromMap(e.data())).toList();
  songCatalog = SongCatalog(songs: songList);

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

class SongRequest {
  final int songId;
  final int count;

  SongRequest({
    required this.songId,
    required this.count,
  });
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
            stream: FirebaseFirestore.instance.collection('requests').where('sessionId', isEqualTo: gig.sessionId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final x = snapshot.data!.docs.map((snapshot) {
                  return Request.fromMap(snapshot.data());
                }).groupListsBy((element) => element.songId);

                final songs = <SongRequest>[];

                x.forEach((key, value) {
                  songs.add(SongRequest(songId: key, count: value.length));
                });

                songs.sort((r1, r2) => r2.count.compareTo(r1.count));

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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Requested',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: x.length,
                      itemBuilder: (context, index) {
                        final song = songCatalog.getById(songs[index].songId);

                        if (song == Song.empty) {
                          // This is an unusual case where the songId doesn't match any song
                          // in our catalog, so we'll just skip over it
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: Text(songs[index].count.toString()),
                          title: Text(song.artist),
                          subtitle: Text(song.title),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Played',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}
