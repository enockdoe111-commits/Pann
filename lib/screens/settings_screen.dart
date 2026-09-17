import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Use dark theme by default.'),
            value: appState.isDarkMode,
            onChanged: (value) async {
              await appState.setTheme(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rescan music'),
            subtitle: const Text('Refresh the local music library.'),
            onTap: () async {
              await appState.scanDeviceMusic();
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Modern Music Player\nOffline local music player for Android.'),
          ),
        ],
      ),
    );
  }
}
