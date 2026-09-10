class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.durationMs,
    this.coverUrl,
    this.bpm,
    this.workoutTags = const [],
  });

  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final int durationMs;
  final String? coverUrl;
  final int? bpm;
  final List<String> workoutTags;

  String get durationLabel {
    final total = Duration(milliseconds: durationMs);
    final m = total.inMinutes;
    final s = total.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      audioUrl: map['audio_url'] as String,
      durationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
      coverUrl: map['cover_url'] as String?,
      bpm: (map['bpm'] as num?)?.toInt(),
      workoutTags: (map['workout_tags'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'audio_url': audioUrl,
        'duration_ms': durationMs,
        'cover_url': coverUrl,
        'bpm': bpm,
        'workout_tags': workoutTags,
      };
}
