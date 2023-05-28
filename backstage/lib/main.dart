import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'package:common/gig.dart';
import 'package:common/request.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final data = await FirebaseFirestore.instance.collection('requests').get();

  // for (final d in data.docs) {
  //   print(d);
  // }

  runApp(const MyApp());
}

class BackstageDrawer extends StatelessWidget {
  const BackstageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 76, 212, 221),
            ),
            child: Text('BACKSTAGE'),
          ),
          ListTile(
            title: const Text('Start Session'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StartSessionPage()),
              );
            },
          ),
        ],
      ),
    );
  }
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
  final String title;
  final int count;

  SongRequest({
    required this.title,
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
      stream: FirebaseFirestore.instance.collection('gigs').doc('current').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // This is the waiting phase for the initial "get the current session"
          // call. This shows nothing since this happens pretty fast, while the
          // next one--retrieving the songs--could be longer, so THAT one gets
          // the progress indicator.
          return const SizedBox(
            width: 1,
            height: 1,
          );
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
                }).groupListsBy((element) => element.song);

                final songs = <SongRequest>[];

                x.forEach((key, value) {
                  songs.add(SongRequest(title: key, count: value.length));
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Requests',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: x.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Text(songs[index].count.toString()),
                          title: Text(songs[index].title),
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

class StartSessionPage extends StatefulWidget {
  const StartSessionPage({
    super.key,
  });

  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  final sessionNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe this session',
              ),
              controller: sessionNameController,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final gig = Gig(
                        sessionId: const Uuid().v4(),
                        title: sessionNameController.value.text,
                        startTime: DateTime.now(),
                      );

                      FirebaseFirestore.instance.collection('gigs').doc('current').update(gig.toMap());
                      Navigator.pop(context);
                    },
                    child: const Text('Start Session'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sessionNameController.dispose();
    super.dispose();
  }
}
