import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:spotfit/core/config.dart';
import 'package:spotfit/data/demo_catalog.dart';
import 'package:spotfit/models/playlist.dart';
import 'package:spotfit/models/track.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({SupabaseClient? client, required this.userId})
      : _client = client;

  SupabaseClient? _client;
  String userId;
  final _uuid = const Uuid();

  List<Track> tracks = [];
  List<Playlist> playlists = [];
  Set<String> favoriteIds = {};
  bool loading = false;
  String? errorMessage;

  bool get remote => _client != null;

  void rebind({required String userId, SupabaseClient? client}) {
    if (this.userId == userId && _client == client) return;
    this.userId = userId;
    _client = client;
    Future<void>(() => load());
  }

  List<Playlist> officialPlaylists() =>
      playlists.where((item) => item.isOfficial).toList();

  List<Playlist> userPlaylists() =>
      playlists.where((item) => !item.isOfficial && item.userId == userId).toList();

  List<Track> favorites() =>
      tracks.where((track) => favoriteIds.contains(track.id)).toList();

  List<Track> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return tracks;
    return tracks
        .where((track) =>
            track.title.toLowerCase().contains(needle) ||
            track.artist.toLowerCase().contains(needle) ||
            track.workoutTags.any((tag) => tag.contains(needle)))
        .toList();
  }

  List<Playlist> byWorkout(String type) =>
      playlists.where((item) => item.workoutType == type).toList();

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (remote) {
        await _loadRemote();
      } else {
        tracks = List.of(demoTracks);
        playlists = buildOfficialPlaylists();
      }
    } catch (error) {
      errorMessage = error.toString();
      tracks = List.of(demoTracks);
      playlists = buildOfficialPlaylists();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemote() async {
    final client = _client!;
    final trackRows = await client.from('tracks').select();
    tracks = (trackRows as List)
        .map((row) => Track.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();

    final playlistRows = await client
        .from('playlists')
        .select()
        .or('is_official.eq.true,user_id.eq.$userId');
    final rawPlaylists = (playlistRows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final junction = await client.from('playlist_tracks').select();
    final byPlaylist = <String, List<Map<String, dynamic>>>{};
    for (final row in junction as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['playlist_id'] as String;
      byPlaylist.putIfAbsent(id, () => []).add(map);
    }

    final trackById = {for (final track in tracks) track.id: track};
    playlists = rawPlaylists.map((row) {
      final items = (byPlaylist[row['id']] ?? [])
        ..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));
      final playlistTracks = items
          .map((item) => trackById[item['track_id'] as String])
          .whereType<Track>()
          .toList();
      return Playlist.fromMap(row, tracks: playlistTracks);
    }).toList();

    final favRows = await client
        .from('favorites')
        .select('track_id')
        .eq('user_id', userId);
    favoriteIds = {
      for (final row in favRows as List)
        Map<String, dynamic>.from(row as Map)['track_id'] as String,
    };
  }

  Future<void> toggleFavorite(Track track) async {
    final liked = favoriteIds.contains(track.id);
    if (liked) {
      favoriteIds.remove(track.id);
      if (remote) {
        await _client!
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('track_id', track.id);
      }
    } else {
      favoriteIds.add(track.id);
      if (remote) {
        await _client!.from('favorites').insert({
          'user_id': userId,
          'track_id': track.id,
        });
      }
    }
    notifyListeners();
  }

  Future<Playlist> createPlaylist({
    required String title,
    required String workoutType,
    String? description,
    List<Track> selected = const [],
  }) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      title: title,
      workoutType: workoutType,
      description: description,
      userId: userId,
      isOfficial: false,
      tracks: selected,
      coverUrl: selected.isNotEmpty ? selected.first.coverUrl : null,
    );

    if (remote) {
      final client = _client!;
      await client.from('playlists').insert({
        'id': playlist.id,
        'user_id': userId,
        'title': title,
        'description': description,
        'workout_type': workoutType,
        'is_official': false,
        'cover_url': playlist.coverUrl,
      });
      if (selected.isNotEmpty) {
        await client.from('playlist_tracks').insert([
          for (var i = 0; i < selected.length; i++)
            {
              'playlist_id': playlist.id,
              'track_id': selected[i].id,
              'position': i,
            },
        ]);
      }
    }

    playlists = [...playlists, playlist];
    notifyListeners();
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    playlists = playlists.where((item) => item.id != id).toList();
    if (remote) {
      await _client!.from('playlists').delete().eq('id', id).eq('user_id', userId);
    }
    notifyListeners();
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final index = playlists.indexWhere((item) => item.id == playlistId);
    if (index < 0) return;
    final current = playlists[index];
    if (current.tracks.any((item) => item.id == track.id)) return;
    final updated = current.copyWith(tracks: [...current.tracks, track]);
    playlists = [...playlists]..[index] = updated;
    if (remote) {
      await _client!.from('playlist_tracks').insert({
        'playlist_id': playlistId,
        'track_id': track.id,
        'position': updated.tracks.length - 1,
      });
    }
    notifyListeners();
  }

  Future<String> shareLinkFor(Playlist playlist) async {
    if (!remote) {
      return AppConfig.shareUri('demo-${playlist.id}');
    }
    final client = _client!;
    final existing = await client
        .from('playlist_share_links')
        .select('token')
        .eq('playlist_id', playlist.id)
        .maybeSingle();
    if (existing != null && existing['token'] is String) {
      return AppConfig.shareUri(existing['token'] as String);
    }
    final inserted = await client
        .from('playlist_share_links')
        .insert({
          'playlist_id': playlist.id,
          'created_by': userId,
        })
        .select('token')
        .single();
    return AppConfig.shareUri(inserted['token'] as String);
  }

  Future<Playlist?> playlistFromShareToken(String token) async {
    if (!remote) {
      final id = token.startsWith('demo-') ? token.substring(5) : token;
      for (final item in playlists) {
        if (item.id == id) return item;
      }
      return null;
    }
    final raw = await _client!.rpc('get_shared_playlist', params: {'p_token': token});
    if (raw == null) return null;
    final data = Map<String, dynamic>.from(
      raw is String ? jsonDecode(raw) as Map : raw as Map,
    );
    final playlistMap = Map<String, dynamic>.from(data['playlist'] as Map);
    final trackRows = (data['tracks'] as List?) ?? const [];
    final tracks = trackRows
        .map((row) => Track.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    return Playlist.fromMap(playlistMap, tracks: tracks);
  }
}
