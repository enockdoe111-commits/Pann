import 'package:hive_flutter/hive_flutter.dart';
import 'package:modern_music_player/models/playlist_model.dart';
import 'package:modern_music_player/models/song_model.dart';

class LocalStorageService {
  static late Box _favoritesBox;
  static late Box _recentBox;
  static late Box _playlistsBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    _favoritesBox = await Hive.openBox('favorites');
    _recentBox = await Hive.openBox('recent');
    _playlistsBox = await Hive.openBox('playlists');
    _settingsBox = await Hive.openBox('settings');
  }

  static List<SongModel> _readSongs(Box box) {
    final raw = box.get('songs', defaultValue: const <Map<String, dynamic>>[]);
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((entry) => SongModel.fromMap(Map<String, dynamic>.from(entry)))
        .toList();
  }

  static List<PlaylistModel> get playlists {
    final raw = _playlistsBox.get('playlists', defaultValue: const <Map<String, dynamic>>[]);
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((entry) => PlaylistModel.fromMap(Map<String, dynamic>.from(entry)))
        .toList();
  }

  static List<SongModel> get favoriteSongs => _readSongs(_favoritesBox);
  static List<SongModel> get recentSongs => _readSongs(_recentBox);
  static bool get isDarkMode => _settingsBox.get('darkMode', defaultValue: true) as bool;

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('darkMode', value);
  }

  static Future<void> toggleFavorite(SongModel song) async {
    final current = favoriteSongs;
    final contains = current.any((item) => item.id == song.id);
    final updated = contains
        ? current.where((item) => item.id != song.id).toList()
        : [...current, song];

    await _favoritesBox.put('songs', updated.map((song) => song.toMap()).toList());
  }

  static Future<void> saveRecentSong(SongModel song) async {
    final current = recentSongs;
    final withoutCurrent = current.where((item) => item.id != song.id).toList();
    final updated = [song, ...withoutCurrent].take(12).toList();
    await _recentBox.put('songs', updated.map((song) => song.toMap()).toList());
  }

  static Future<void> createPlaylist(String name) async {
    final current = playlists;
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: const [],
    );

    await _playlistsBox.put('playlists', [...current, playlist].map((playlist) => playlist.toMap()).toList());
  }

  static Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    final current = playlists;
    final updated = current.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }
      if (playlist.songs.any((item) => item.id == song.id)) {
        return playlist;
      }
      return PlaylistModel(
        id: playlist.id,
        name: playlist.name,
        songs: [...playlist.songs, song],
      );
    }).toList();

    await _playlistsBox.put('playlists', updated.map((playlist) => playlist.toMap()).toList());
  }

  static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final current = playlists;
    final updated = current.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }
      return PlaylistModel(
        id: playlist.id,
        name: playlist.name,
        songs: playlist.songs.where((song) => song.id != songId).toList(),
      );
    }).toList();

    await _playlistsBox.put('playlists', updated.map((playlist) => playlist.toMap()).toList());
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final current = playlists.where((playlist) => playlist.id != playlistId).toList();
    await _playlistsBox.put('playlists', current.map((playlist) => playlist.toMap()).toList());
  }
}
