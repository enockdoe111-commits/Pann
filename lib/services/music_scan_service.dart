import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:modern_music_player/models/song_model.dart';

class MusicScanService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModel>> scanForSongs() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      return [];
    }

    final songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_DESC,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs
        .where((song) => song.data.isNotEmpty)
        .map((song) => SongModel(
              id: song.id.toString(),
              title: song.title.isEmpty ? 'Unknown Title' : song.title,
              artist: song.artist?.isNotEmpty == true ? song.artist! : 'Unknown Artist',
              album: song.album?.isNotEmpty == true ? song.album! : 'Unknown Album',
              durationMs: song.duration ?? 0,
              uri: song.uri ?? '',
              albumArtPath: song.data,
            ))
        .toList();
  }

  Future<bool> _requestPermission() async {
    if (await Permission.audio.isGranted) {
      return true;
    }

    final status = await Permission.audio.request();
    if (status.isGranted) {
      return true;
    }

    return false;
  }
}
