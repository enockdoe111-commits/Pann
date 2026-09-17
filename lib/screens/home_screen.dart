import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';
import 'package:modern_music_player/models/song_model.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final recent = appState.recentSongs;
    final favorites = appState.favoriteSongs;
    final songs = appState.filteredSongs.isEmpty ? appState.allSongs : appState.filteredSongs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              final controller = TextEditingController(text: appState.searchQuery);
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Search music'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Song, artist, album'),
                      onChanged: (value) {
                        appState.searchQuery = value;
                        appState.notifyListeners();
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
        onRefresh: () async => appState.scanDeviceMusic(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Recently played'),
            if (recent.isEmpty)
              const Text('No recent songs yet.')
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  itemBuilder: (_, index) {
                    final song = recent[index];
                    return _songCard(context, song, appState);
                  },
                ),
              ),
            const SizedBox(height: 24),
            _sectionTitle('Favorites'),
            if (favorites.isEmpty)
              const Text('Tap the heart to save favorites.')
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  itemBuilder: (_, index) {
                    final song = favorites[index];
                    return _songCard(context, song, appState);
                  },
                ),
              ),
            const SizedBox(height: 24),
            _sectionTitle('All songs'),
            if (songs.isEmpty)
              const Text('No music found on this device. Try rescan in Settings.')
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
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
          width: 140,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 84,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF00C2A8)],
                      ),
                    ),
                    child: const Icon(Icons.music_note, size: 40, color: Colors.white),
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
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF00C2A8)],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      title: Text(song.title),
      subtitle: Text('${song.artist} • ${song.durationText}'),
      trailing: IconButton(
        icon: Icon(
          appState.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
          color: appState.isFavorite(song.id) ? Colors.pink : null,
        ),
        onPressed: () => appState.toggleFavorite(song),
      ),
      onTap: () => appState.playSong(song),
    );
  }
}
