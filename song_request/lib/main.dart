import 'package:cloud_firestore/cloud_firestore.dart';
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
      home: const Scaffold(
        body: MyHomePage(),
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
        if (snapshot.hasData) {
          var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          final gig = Gig.fromMap(data.data()!);

          if (gig.sessionId.isEmpty) {
            return const Text('Not taking requests right now');
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        gig.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final songPool = items[index];

                          if (songPool.wasPlayed) {
                            return const SizedBox.shrink();
                          }

                          final song = songCatalog.getById(songPool.songId);
                          return ListTile(
                            title: Text(song.artist),
                            subtitle: Text(song.title),
                            onTap: () {
                              final documentId = items[index].id;
                              final docRef = FirebaseFirestore.instance.collection('song_pool').doc(documentId);
                              docRef.update({'requests': FieldValue.increment(1)});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('error');
              } else {
                return const Text('still working on it');
              }
            },
          );
        } else if (snapshot.hasError) {
          return const Text('error');
        } else {
          return const Text('working on it');
        }
      },
    );
  }
}
