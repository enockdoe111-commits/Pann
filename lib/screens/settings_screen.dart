import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Toggle the app theme.'),
            value: appState.isDarkMode,
            onChanged: (value) async {
              await appState.setTheme(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rescan music'),
            subtitle: const Text('Scan your phone again for local songs.'),
            onTap: () async {
              await appState.scanDeviceMusic();
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Modern Music Player\nOffline music player for local Android files.'),
          ),
        ],
      ),
    );
  }
}
