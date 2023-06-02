import 'package:backstage/start_session_page.dart';
import 'package:flutter/material.dart';

class BackstageDrawer extends StatelessWidget {
  final Function() stopSession;

  const BackstageDrawer({
    super.key,
    required this.stopSession,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                  leading: const Icon(
                    Icons.play_arrow,
                  ),
                  title: const Text('Start Session'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StartSessionPage()),
                    );
                  },
                ),
                // ListTile(
                //   title: const Text('All Songs'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const AllSongsPage()),
                //     );
                //   },
                // ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.stop,
            ),
            title: const Text('Stop Session'),
            onTap: () {
              Navigator.pop(context);
              stopSession();
            },
          ),
        ],
      ),
    );
  }
}
