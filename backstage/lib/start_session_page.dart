import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/gig.dart';
import 'package:common/song.dart';
import 'package:common/song_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class SongPoolList extends StatefulWidget {
  final List<Song> songs;

  const SongPoolList({
    super.key,
    required this.songs,
  });

  @override
  State<SongPoolList> createState() => _SongPoolListState();
}

class _SongPoolListState extends State<SongPoolList> {
  late final Map<int, bool> values = {};

  @override
  void initState() {
    super.initState();

    for (final song in widget.songs) {
      values[song.id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: widget.songs.map((s) {
        return CheckboxListTile(
          title: Text(s.artist),
          subtitle: Text(s.title),
          value: values[s.id],
          onChanged: (value) => setState(() => values[s.id] = value ?? true),
        );
      }).toList(),
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
    final songCatalog = GetIt.instance.get<SongCatalog>();

    final key = GlobalKey<_SongPoolListState>();

    final songListWidget = SongPoolList(
      key: key,
      songs: songCatalog.songs,
    );

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
            Expanded(
              child: songListWidget,
            ),
            Align(
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

                    // Write every checked song as a SongPoolEntry to SongPool

                    final includedSongs = <Song>[];
                    final checkedStates = key.currentState!.values;

                    for (final checkState in checkedStates.entries) {
                      if (checkState.value) {
                        final song = songCatalog.getById(checkState.key);
                        includedSongs.add(song);
                      }
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Start Session'),
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
