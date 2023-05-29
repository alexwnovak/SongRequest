import 'package:backstage/start_session_page.dart';
import 'package:flutter/material.dart';

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
