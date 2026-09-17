import 'song_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final List<SongModel> songs;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songs,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songs': songs.map((song) => song.toMap()).toList(),
      };

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    final rawSongs = map['songs'];
    final songsList = rawSongs is List ? rawSongs : const <dynamic>[];
    final songs = songsList
        .whereType<Map>()
        .map((entry) => SongModel.fromMap(Map<String, dynamic>.from(entry)))
        .toList();

    return PlaylistModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'Playlist').toString(),
      songs: songs,
    );
  }
}
