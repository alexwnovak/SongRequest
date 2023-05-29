import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/gig.dart';
import 'package:flutter/material.dart';
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
