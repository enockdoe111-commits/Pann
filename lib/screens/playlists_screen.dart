import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';
import 'package:modern_music_player/models/playlist_model.dart';

class PlaylistsScreen extends StatelessWidget {
  final AppState appState;

  const PlaylistsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
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
                  autofocus: true,
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
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
      body: appState.playlists.isEmpty
          ? const Center(child: Text('No playlists yet. Create one to start organizing your music.'))
          : ListView.builder(
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
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (playlist.songs.isEmpty)
                        const Text('This playlist is empty.')
                      else
                        ...playlist.songs.map((song) => ListTile(
                              title: Text(song.title),
                              subtitle: Text(song.artist),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  appState.removeSongFromPlaylist(playlist.id, song.id);
                                  Navigator.pop(context);
                                },
                              ),
                              onTap: () => appState.playSong(song),
                            )),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await appState.playPlaylist(playlist);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Play playlist'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
