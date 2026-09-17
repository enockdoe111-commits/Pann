import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';

class PlayerScreen extends StatelessWidget {
  final AppState appState;

  const PlayerScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final song = appState.currentSong;

    if (song == null) {
      return const Scaffold(
        body: Center(child: Text('No song selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF00C2A8)],
                      ),
                    ),
                    child: const Icon(Icons.music_note, size: 120, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    song.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artist,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: appState,
                    builder: (context, _) {
                      final current = appState.position;
                      final total = appState.duration;
                      return Column(
                        children: [
                          Slider(
                            value: total.inMilliseconds > 0
                                ? current.inMilliseconds.clamp(0, total.inMilliseconds).toDouble()
                                : 0,
                            max: total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1,
                            onChanged: (value) async {
                              await appState.seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(current)),
                                Text(_formatDuration(total)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => appState.toggleShuffle(),
                        icon: Icon(
                          Icons.shuffle,
                          color: appState.shuffleEnabled ? Colors.greenAccent : Colors.white,
                        ),
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: () => appState.playPrevious(),
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 38,
                      ),
                      FloatingActionButton.large(
                        onPressed: () => appState.togglePlayPause(),
                        child: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      IconButton(
                        onPressed: () => appState.playNext(),
                        icon: const Icon(Icons.skip_next),
                        iconSize: 38,
                      ),
                      IconButton(
                        onPressed: () => appState.toggleRepeat(),
                        icon: Icon(
                          Icons.repeat,
                          color: appState.repeatEnabled ? Colors.greenAccent : Colors.white,
                        ),
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => appState.toggleFavorite(song),
                        icon: Icon(
                          appState.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                          color: appState.isFavorite(song.id) ? Colors.pink : Colors.white,
                        ),
                        iconSize: 32,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
