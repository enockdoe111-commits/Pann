import 'package:flutter/material.dart';
import 'package:modern_music_player/main.dart';

class MiniPlayer extends StatelessWidget {
  final AppState appState;
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.appState, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final song = appState.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => appState.togglePlayPause(),
              icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              onPressed: () => appState.playNext(),
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
      ),
    );
  }
}
