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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Music Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C4DFF),
          secondary: Color(0xFF00C2A8),
          surface: Color(0xFF161B22),
          background: Color(0xFF0D1117),
        ),
        cardColor: const Color(0xFF161B22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1117),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF111827),
          indicatorColor: Color(0xFF7C4DFF),
        ),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _appState.loadLibrary();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(appState: _appState),
      SongsScreen(appState: _appState),
      PlaylistsScreen(appState: _appState),
      SettingsScreen(appState: _appState),
    ];

    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
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
                if (_appState.currentSong != null)
                  MiniPlayer(
                    appState: _appState,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(appState: _appState),
                        ),
                      );
                    },
                  ),
                NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
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
      },
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
  String searchQuery = '';

  late final Stream<dynamic> _playerPositionStream;

  AppState() {
    _playerPositionStream = _audioService.positionStream;
    _playerPositionStream.listen((_) {
      notifyListeners();
    });
    _audioService.playerStateStream.listen((_) {
      isPlaying = _audioService.isPlaying;
      notifyListeners();
    });
  }

  AudioPlayerService get audioService => _audioService;

  Duration get position => _audioService.position;
  Duration get duration => _audioService.duration;

  Future<void> loadLibrary() async {
    await LocalStorageService.loadSettings();
    isDarkMode = LocalStorageService.isDarkMode;
    favoriteSongs = LocalStorageService.favoriteSongs;
    recentSongs = LocalStorageService.recentSongs;
    playlists = LocalStorageService.playlists;
    await scanDeviceMusic();
    notifyListeners();
  }

  Future<void> scanDeviceMusic() async {
    isScanning = true;
    notifyListeners();
    final songs = await _scanService.scanForSongs();
    allSongs = songs;
    isScanning = false;
    notifyListeners();
  }

  List<SongModel> get filteredSongs {
    if (searchQuery.trim().isEmpty) {
      return allSongs;
    }
    final query = searchQuery.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> playSong(SongModel song) async {
    currentSong = song;
    final queue = allSongs.isEmpty ? [song] : allSongs;
    await _audioService.playQueue(queue, startIndex: queue.indexOf(song));
    await LocalStorageService.saveRecentSong(song);
    recentSongs = LocalStorageService.recentSongs;
    isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      if (currentSong != null) {
        await _audioService.resume();
      }
    }
    isPlaying = _audioService.isPlaying;
    notifyListeners();
  }

  Future<void> playNext() async {
    if (allSongs.isEmpty || currentSong == null) {
      return;
    }
    final index = allSongs.indexWhere((song) => song.id == currentSong!.id);
    final nextIndex = index + 1 < allSongs.length ? index + 1 : 0;
    await playSong(allSongs[nextIndex]);
  }

  Future<void> playPrevious() async {
    if (allSongs.isEmpty || currentSong == null) {
      return;
    }
    final index = allSongs.indexWhere((song) => song.id == currentSong!.id);
    final previousIndex = index - 1 >= 0 ? index - 1 : allSongs.length - 1;
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

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    await LocalStorageService.addSongToPlaylist(playlistId, song);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    if (name.trim().isEmpty) return;
    await LocalStorageService.createPlaylist(name);
    playlists = LocalStorageService.playlists;
    notifyListeners();
  }

  Future<void> deletePlaylist(PlaylistModel playlist) async {
    await LocalStorageService.deletePlaylist(playlist.id);
    playlists = LocalStorageService.playlists;
    notifyListeners();
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

  Future<void> setTheme(bool value) async {
    isDarkMode = value;
    await LocalStorageService.setDarkMode(value);
    notifyListeners();
  }

  Future<void> playPlaylist(PlaylistModel playlist) async {
    final songs = playlist.songs;
    if (songs.isEmpty) return;
    currentSong = songs.first;
    await _audioService.playQueue(songs, startIndex: 0);
    await LocalStorageService.saveRecentSong(currentSong!);
    recentSongs = LocalStorageService.recentSongs;
    isPlaying = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
