import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/gig.dart';
import 'package:common/song_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

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
    final songCatalog = GetIt.instance.get<SongCatalog>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe this session',
              ),
              controller: sessionNameController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Songs',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: songCatalog.songs.map((s) {
                return ListTile(
                  leading: Checkbox(
                    value: true,
                    onChanged: (v) {},
                  ),
                  title: Text(s.artist),
                  subtitle: Text(s.title),
                );
              }).toList(),
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
