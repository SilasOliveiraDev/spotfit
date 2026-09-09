import 'package:spotfit/models/track.dart';

class Playlist {
  const Playlist({
    required this.id,
    required this.title,
    required this.workoutType,
    this.description,
    this.coverUrl,
    this.userId,
    this.isPublic = false,
    this.isOfficial = false,
    this.tracks = const [],
  });

  final String id;
  final String title;
  final String workoutType;
  final String? description;
  final String? coverUrl;
  final String? userId;
  final bool isPublic;
  final bool isOfficial;
  final List<Track> tracks;

  Playlist copyWith({List<Track>? tracks, String? title, bool? isPublic}) {
    return Playlist(
      id: id,
      title: title ?? this.title,
      workoutType: workoutType,
      description: description,
      coverUrl: coverUrl,
      userId: userId,
      isPublic: isPublic ?? this.isPublic,
      isOfficial: isOfficial,
      tracks: tracks ?? this.tracks,
    );
  }

  factory Playlist.fromMap(Map<String, dynamic> map, {List<Track> tracks = const []}) {
    return Playlist(
      id: map['id'] as String,
      title: map['title'] as String,
      workoutType: (map['workout_type'] as String?) ?? 'treino',
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      userId: map['user_id'] as String?,
      isPublic: map['is_public'] as bool? ?? false,
      isOfficial: map['is_official'] as bool? ?? false,
      tracks: tracks,
    );
  }
}
