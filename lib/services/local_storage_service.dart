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

  static List<SongModel> get favoriteSongs {
    final items = (_favoritesBox.get('songs', defaultValue: []) as List).cast<Map>();
    return items.map((map) => SongModel.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  static List<SongModel> get recentSongs {
    final items = (_recentBox.get('songs', defaultValue: []) as List).cast<Map>();
    return items.map((map) => SongModel.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  static List<PlaylistModel> get playlists {
    final items = (_playlistsBox.get('playlists', defaultValue: []) as List).cast<Map>();
    return items.map((map) => PlaylistModel.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  static bool get isDarkMode => _settingsBox.get('darkMode', defaultValue: true) as bool;

  static Future<void> loadSettings() async {
    _settingsBox.get('darkMode', defaultValue: true);
  }

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('darkMode', value);
  }

  static Future<void> toggleFavorite(SongModel song) async {
    final current = favoriteSongs;
    final ids = current.map((item) => item.id).toList();
    if (ids.contains(song.id)) {
      final filtered = current.where((item) => item.id != song.id).toList();
      await _favoritesBox.put('songs', filtered.map((item) => item.toMap()).toList());
    } else {
      final updated = [...current, song];
      await _favoritesBox.put('songs', updated.map((item) => item.toMap()).toList());
    }
  }

  static Future<void> saveRecentSong(SongModel song) async {
    final current = recentSongs;
    final filtered = current.where((item) => item.id != song.id).toList();
    final updated = [song, ...filtered].take(12).toList();
    await _recentBox.put('songs', updated.map((item) => item.toMap()).toList());
  }

  static Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: const [],
    );
    final current = playlists;
    await _playlistsBox.put('playlists', [...current, playlist].map((p) => p.toMap()).toList());
  }

  static Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    final current = playlists;
    final updated = current.map((playlist) {
      if (playlist.id == playlistId) {
        if (playlist.songs.any((item) => item.id == song.id)) {
          return playlist;
        }
        return PlaylistModel(
          id: playlist.id,
          name: playlist.name,
          songs: [...playlist.songs, song],
        );
      }
      return playlist;
    }).toList();
    await _playlistsBox.put('playlists', updated.map((p) => p.toMap()).toList());
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final current = playlists.where((playlist) => playlist.id != playlistId).toList();
    await _playlistsBox.put('playlists', current.map((p) => p.toMap()).toList());
  }
}
