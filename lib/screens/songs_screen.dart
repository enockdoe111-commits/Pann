import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';
import 'package:modern_music_player/models/song_model.dart';

class SongsScreen extends StatelessWidget {
  final AppState appState;

  const SongsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
        actions: [
          IconButton(
            onPressed: () async {
              await appState.scanDeviceMusic();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search songs, artists, albums',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: (value) {
                appState.setSearchQuery(value);
              },
            ),
          ),
          if (appState.scanMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(appState.scanMessage),
            ),
          Expanded(
            child: appState.allSongs.isEmpty
                ? const Center(
                    child: Text('No songs found on this device.\nPlease allow music access.'),
                  )
                : ListView.builder(
                    itemCount: appState.filteredSongs.length,
                    itemBuilder: (_, index) {
                      final song = appState.filteredSongs[index];
                      return _songTile(context, song, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _songTile(BuildContext context, SongModel song, AppState appState) {
    final isFavorite = appState.isFavorite(song.id);
    return ListTile(
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF00C2A8)],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${song.artist} • ${song.album}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(song.durationText),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => appState.toggleFavorite(song),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.pink : null,
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => appState.playlists
                .map((playlist) => PopupMenuItem(
                      value: playlist.id,
                      child: Text(playlist.name),
                    ))
                .toList(),
            onSelected: (playlistId) {
              appState.addSongToPlaylist(playlistId, song);
            },
            child: const Icon(Icons.playlist_add),
          ),
        ],
      ),
      onTap: () => appState.playSong(song),
    );
  }
}
