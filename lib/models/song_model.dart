class SongModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String uri;
  final String? albumArtPath;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.uri,
    this.albumArtPath,
  });

  String get durationText {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'durationMs': durationMs,
        'uri': uri,
        'albumArtPath': albumArtPath,
      };

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id']?.toString() ?? 'unknown',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      durationMs: map['durationMs'] ?? 0,
      uri: map['uri'] ?? '',
      albumArtPath: map['albumArtPath'],
    );
  }
}
