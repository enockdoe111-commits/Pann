import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modern_music_player/models/song_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _queue = const [];
  int _currentIndex = 0;

  AudioPlayerService() {
    _configureSession();
  }

  AudioPlayer get player => _player;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = songs;
    _currentIndex = startIndex.clamp(0, songs.length > 0 ? songs.length - 1 : 0);

    if (songs.isEmpty) {
      await _player.stop();
      return;
    }

    final validSongs = songs.where((song) => song.uri.isNotEmpty).toList();
    if (validSongs.isEmpty) {
      return;
    }

    final sources = validSongs
        .map((song) => AudioSource.uri(Uri.parse(song.uri)))
        .toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex.clamp(0, validSongs.length - 1),
    );
  }

  Future<void> play() async {
    if (_player.processingState == ProcessingState.idle && _queue.isNotEmpty) {
      await _player.play();
      return;
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration value) async {
    await _player.seek(value);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeat(bool enabled) async {
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
  }

  Future<void> next() async {
    if (_queue.isEmpty) {
      return;
    }
    final nextIndex = (_currentIndex + 1) % _queue.length;
    _currentIndex = nextIndex;
    await _player.seek(Duration.zero, index: nextIndex);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) {
      return;
    }
    final previousIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    _currentIndex = previousIndex;
    await _player.seek(Duration.zero, index: previousIndex);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
