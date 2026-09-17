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
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Unknown Title').toString(),
      artist: (map['artist'] ?? 'Unknown Artist').toString(),
      album: (map['album'] ?? 'Unknown Album').toString(),
      durationMs: int.tryParse(map['durationMs']?.toString() ?? '') ?? 0,
      uri: (map['uri'] ?? '').toString(),
      albumArtPath: map['albumArtPath']?.toString(),
    );
  }
}
