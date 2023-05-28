import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'package:common/gig.dart';

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
          title: const Text('Backstage'),
        ),
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
      stream: FirebaseFirestore.instance.collection('gigs').doc('current').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('working on it'),
          );
        } else {
          final snapshotData = snapshot.data! as DocumentSnapshot<Map<String, dynamic>>;
          final gig = Gig.fromMap(snapshotData.data()!);

          if (gig.sessionId.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StartSessionPage()),
                  );
                },
                child: const Text('Start session'),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (gig.sessionId.isEmpty) Text('No session') else Text(gig.sessionId),
              Text(gig.title),
              Text(gig.startTime.toString()),
            ],
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

  void _onSessionNameChanged() {
    print('Latst value: ${sessionNameController.value}');
  }

  @override
  void initState() {
    super.initState();

    sessionNameController.addListener(_onSessionNameChanged);
  }

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

                      print('Create with ${gig.toString()}');
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
