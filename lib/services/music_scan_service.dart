import 'dart:io';

import 'package:modern_music_player/models/song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicScanService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool hasPermission = false;

  Future<List<SongModel>> scanForSongs() async {
    hasPermission = await _requestPermission();
    if (!hasPermission) {
      return const [];
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
    if (Platform.isAndroid) {
      final sdk = Platform.version;
      final versionInt = int.tryParse(sdk.split(' ').first.split('.').first) ?? 0;
      final permissions = <Permission>[];

      if (versionInt >= 33) {
        permissions.add(Permission.audio);
      } else {
        permissions.add(Permission.storage);
      }

      final statuses = await permissions.request();
      final granted = statuses.values.every((status) => status.isGranted);
      return granted;
    }

    return true;
  }
}
