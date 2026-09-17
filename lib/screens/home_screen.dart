import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';
import 'package:modern_music_player/models/playlist_model.dart';
import 'package:modern_music_player/models/song_model.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final recent = appState.recentSongs;
    final favorites = appState.favoriteSongs;
    final songs = appState.filteredSongs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              final controller = TextEditingController(text: appState.searchQuery);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Search local library'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Song, artist, or album',
                      ),
                      onChanged: (value) {
                        appState.setSearchQuery(value);
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: appState.scanDeviceMusic,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (appState.scanMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Text(appState.scanMessage),
              ),
            _sectionTitle('Recently played'),
            if (recent.isEmpty)
              const Text('No recently played songs yet.')
            else
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  itemBuilder: (_, index) {
                    return _songCard(context, recent[index], appState);
                  },
                ),
              ),
            const SizedBox(height: 22),
            _sectionTitle('Favorites'),
            if (favorites.isEmpty)
              const Text('Tap the heart on a song to save it.')
            else
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  itemBuilder: (_, index) {
                    return _songCard(context, favorites[index], appState);
                  },
                ),
              ),
            const SizedBox(height: 22),
            _sectionTitle('All songs'),
            if (songs.isEmpty)
              const Text('No music found on this device.')
            else
              ...songs.take(8).map((song) => _songTile(context, song, appState)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _songCard(BuildContext context, SongModel song, AppState appState) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => appState.playSong(song),
        child: SizedBox(
          width: 150,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 88,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF00C2A8)],
                      ),
                    ),
                    child: const Icon(Icons.music_note, size: 38, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      subtitle: Text('${song.artist} • ${song.durationText}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => appState.toggleFavorite(song),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.pink : null,
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => appState.playlists
                .map(
                  (playlist) => PopupMenuItem(
                    value: playlist.id,
                    child: Text(playlist.name),
                  ),
                )
                .toList(),
            onSelected: (playlistId) {
              appState.addSongToPlaylist(playlistId, song);
            },
            child: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      onTap: () => appState.playSong(song),
    );
  }
}
