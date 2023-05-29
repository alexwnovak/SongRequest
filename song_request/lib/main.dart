import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:common/song.dart';
import 'package:common/request.dart';
import 'package:common/song_catalog.dart';
import 'package:common/song_pool.dart';
import 'package:common/gig.dart';

import 'firebase_options.dart';

late SongCatalog songCatalog;

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('gigs').doc('current').get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          final gig = Gig.fromMap(data.data()!);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('song_pool').where('sessionId', isEqualTo: gig.sessionId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final songPoolData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final songPool = SongPool.fromMap(songPoolData);
                final normalizedSongPool = songPool.songIds.map((songId) => songCatalog.getById(songId)).toList();

                return GroupedListView(
                  elements: normalizedSongPool,
                  groupBy: (element) => element.artist,
                  itemBuilder: (c, element) {
                    return ListTile(
                      title: Text(element.title),
                      onTap: () {
                        final request = Request(
                          sessionId: gig.sessionId,
                          songId: element.id,
                        );

                        FirebaseFirestore.instance.collection('requests').add(request.toMap());
                      },
                    );
                  },
                  groupSeparatorBuilder: (String value) {
                    return Text(value);
                  },
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
