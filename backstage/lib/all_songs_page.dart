import 'package:flutter/material.dart';

class AllSongsPage extends StatefulWidget {
  const AllSongsPage({
    super.key,
  });

  @override
  State<AllSongsPage> createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Songs'),
      ),
      body: Placeholder(),
    );
  }
}
