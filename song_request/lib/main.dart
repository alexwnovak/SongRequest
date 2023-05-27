import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:song_request/song.dart';

import 'firebase_options.dart';
import 'gig.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final allSongs = await rootBundle.loadString('assets/all_songs.csv');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          final gig = Gig.fromFirestore(data, null);

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('song_pool').where('sessionId', isEqualTo: gig.sessionId).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GroupedListView(
                  elements: snapshot.data!.docs
                      .map((DocumentSnapshot doc) {
                        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                        return Song.fromMap(data);
                      })
                      .where((element) => element.wasPlayed == false)
                      .toList(),
                  groupBy: (element) => element.artist,
                  itemBuilder: (c, element) {
                    return ListTile(
                      title: Text(element.title),
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
