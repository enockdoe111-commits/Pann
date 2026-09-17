import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modern_music_player/models/playlist_model.dart';
import 'package:modern_music_player/models/song_model.dart';
import 'package:modern_music_player/screens/home_screen.dart';
import 'package:modern_music_player/screens/player_screen.dart';
import 'package:modern_music_player/screens/playlists_screen.dart';
import 'package:modern_music_player/screens/settings_screen.dart';
import 'package:modern_music_player/screens/songs_screen.dart';
import 'package:modern_music_player/services/audio_player_service.dart';
import 'package:modern_music_player/services/local_storage_service.dart';
import 'package:modern_music_player/services/music_scan_service.dart';
import 'package:modern_music_player/widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalStorageService.init();
  runApp(const ModernMusicPlayerApp());
}

class ModernMusicPlayerApp extends StatelessWidget {
  const ModernMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      child: Builder(
        builder: (context) {
          final appState = AppStateScope.of(context);
          return AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Modern Music Player',
                themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData.light(useMaterial3: true).copyWith(
                  scaffoldBackgroundColor: const Color(0xFFF5F7FF),
                  cardColor: Colors.white,
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF7C4DFF),
                    secondary: Color(0xFF00C2A8),
                  ),
                ),
                darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                  scaffoldBackgroundColor: const Color(0xFF0D1117),
                  cardColor: const Color(0xFF161B22),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF7C4DFF),
                    secondary: Color(0xFF00C2A8),
                    surface: Color(0xFF161B22),
                    background: Color(0xFF0D1117),
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF0D1117),
                    foregroundColor: Colors.white,
                  ),
                ),
                home: const AppShell(),
              );
            },
          );
        },
      ),
    );
  }
}

class AppStateScope extends InheritedWidget {
  final AppState appState;

  const AppStateScope({
    super.key,
    required this.appState,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.appState;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => appState != oldWidget.appState;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final appState = AppStateScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await appState.loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final screens = [
      HomeScreen(appState: appState),
      SongsScreen(appState: appState),
      PlaylistsScreen(appState: appState),
      SettingsScreen(appState: appState),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appState.currentSong != null)
              MiniPlayer(
                appState: appState,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(appState: appState),
                    ),
                  );
                },
              ),
            NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: 'Songs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.playlist_play_outlined),
                  selectedIcon: Icon(Icons.playlist_play),
                  label: 'Playlists',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final MusicScanService _scanService = MusicScanService();

  List<SongModel> allSongs = [];
  List<SongModel> recentSongs = [];
  List<SongModel> favoriteSongs = [];
  List<PlaylistModel> playlists = [];
  SongModel? currentSong;
  bool isPlaying = false;
  bool isDarkMode = true;
  bool shuffleEnabled = false;
  bool repeatEnabled = false;
  bool isScanning = false;
  bool hasMusicPermission = false;
  String searchQuery = '';
  String scanMessage = '';

  AppState() {
    _audioService.positionStream.listen((_) {
      notifyListeners();
    });

    _audioService.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
      notifyListeners();
    });
  }

  AudioPlayerService get audioService => _audioService;

  Duration get position => _audioService.position;
  Duration get duration => _audioService.duration;

  Future<void> loadLibrary() async {
    favoriteSongs = LocalStorageService.favoriteSongs;
    recentSongs = LocalStorageService.recentSongs;
    playlists = LocalStorageService.playlists;
    isDarkMode = LocalStorageService.isDarkMode;
    await scanDeviceMusic();
    notifyListeners();
  }

  Future<void> scanDeviceMusic() async {
    isScanning = true;
    scanMessage = '';
    notifyListeners();

    final result = await _scanService.scanForSongs();
    hasMusicPermission = _scanService.hasPermission;

    if (!hasMusicPermission) {
      scanMessage = 'Music access is required to scan the songs stored on your phone.';
      allSongs = [];
      isScanning = false;
      notifyListeners();
      return;
    }

    allSongs = result;
    scanMessage = result.isEmpty ? 'No music files were found on this device.' : '';
    isScanning = false;
    notifyListeners();
  }

  List<SongModel> get filteredSongs {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return allSongs;
    }

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> playSong(SongModel song) async {
    currentSong = song;
    final queue = allSongs.isEmpty ? [song] : allSongs;
    final startIndex = queue.indexWhere((item) => item.id == song.id);
    await _audioService.setQueue(queue, startIndex: startIndex >= 0 ? startIndex : 0);
    await _audioService.play();
    await LocalStorageService.saveRecentSong(song);
    recentSongs = LocalStorageService.recentSongs;
    isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (currentSong == null) {
      if (allSongs.isNotEmpty) {
        await playSong(allSongs.first);
      }
      return;
    }

    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    isPlaying = _audioService.isPlaying;
    notifyListeners();
  }

  Future<void> playNext() async {
    if (allSongs.isEmpty) {
      return;
    }

    final currentIndex = currentSong == null
        ? 0
        : allSongs.indexWhere((song) => song.id == currentSong!.id);

    final nextIndex = currentIndex + 1 < allSongs.length ? currentIndex + 1 : 0;
    await playSong(allSongs[nextIndex]);
  }

  Future<void> playPrevious() async {
    if (allSongs.isEmpty) {
      return;
    }

    final currentIndex = currentSong == null
        ? 0
        : allSongs.indexWhere((song) => song.id == currentSong!.id);

    final previousIndex = currentIndex - 1 >= 0 ? currentIndex - 1 : allSongs.length - 1;
    await playSong(allSongs[previousIndex]);
  }

  Future<void> seekTo(Duration value) async {
    await _audioService.seek(value);
    notifyListeners();
  }

  Future<void> toggleFavorite(SongModel song) async {
    await LocalStorageService.toggleFavorite(song);
    favoriteSongs = LocalStorageService.favoriteSongs;
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return favoriteSongs.any((song) => song.id == songId);
  }

  Future<void> toggleShuffle() async {
    shuffleEnabled = !shuffleEnabled;
    await _audioService.setShuffle(shuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    repeatEnabled = !repeatEnabled;
    await _audioService.setRepeat(repeatEnabled);
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }
    await LocalStorageService.createPlaylist(trimmedName);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> deletePlaylist(PlaylistModel playlist) async {
    await LocalStorageService.deletePlaylist(playlist.id);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    await LocalStorageService.addSongToPlaylist(playlistId, song);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await LocalStorageService.removeSongFromPlaylist(playlistId, songId);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> playPlaylist(PlaylistModel playlist) async {
    if (playlist.songs.isEmpty) {
      return;
    }
    currentSong = playlist.songs.first;
    final startIndex = 0;
    await _audioService.setQueue(playlist.songs, startIndex: startIndex);
    await _audioService.play();
    await LocalStorageService.saveRecentSong(currentSong!);
    recentSongs = LocalStorageService.recentSongs;
    isPlaying = true;
    notifyListeners();
  }

  Future<void> setTheme(bool value) async {
    isDarkMode = value;
    await LocalStorageService.setDarkMode(value);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

class AppStateProvider extends InheritedWidget {
  final AppState appState;

  const AppStateProvider({
    super.key,
    required this.appState,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.appState;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) => appState != oldWidget.appState;
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AppStateProvider(
      appState: appState,
      child: const AppShell(),
    );
  }
}
