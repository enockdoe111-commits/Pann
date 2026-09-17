import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modern_music_player/models/song_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _queue = [];
  int _currentIndex = 0;

  AudioPlayerService() {
    _configureAudioSession();
  }

  AudioPlayer get player => _player;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;
  bool get hasCurrentSong => _queue.isNotEmpty && _currentIndex >= 0;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> playQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = songs;
    _currentIndex = startIndex;

    final sources = songs
        .where((song) => song.uri.isNotEmpty)
        .map((song) => AudioSource.uri(Uri.parse(song.uri)))
        .toList();

    if (sources.isEmpty) return;

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex,
      preload: false,
    );
    await _player.play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> seek(Duration value) async {
    await _player.seek(value);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeat(bool enabled) async {
    if (enabled) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    await _player.seekToNext();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1) % _queue.length;
    await _player.seekToPrevious();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
