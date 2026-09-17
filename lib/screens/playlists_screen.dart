import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';
import 'package:modern_music_player/models/playlist_model.dart';

class PlaylistsScreen extends StatelessWidget {
  final AppState appState;

  const PlaylistsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text('Create Playlist'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Playlist name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await appState.createPlaylist(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: appState.playlists.length,
        itemBuilder: (_, index) {
          final playlist = appState.playlists[index];
          return _playlistTile(context, playlist, appState);
        },
      ),
    );
  }

  Widget _playlistTile(BuildContext context, PlaylistModel playlist, AppState appState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.queue_music),
        ),
        title: Text(playlist.name),
        subtitle: Text('${playlist.songs.length} songs'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            await appState.deletePlaylist(playlist);
          },
        ),
        onTap: () async {
          await appState.playPlaylist(playlist);
        },
      ),
    );
  }
}
