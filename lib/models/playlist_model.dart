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
    final songsData = (map['songs'] as List? ?? []).cast<Map<String, dynamic>>();
    final songs = songsData.map(SongModel.fromMap).toList();

    return PlaylistModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Playlist',
      songs: songs,
    );
  }
}
