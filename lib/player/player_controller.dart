import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotfit/models/track.dart';
import 'package:spotfit/player/playback_queue.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  final PlaybackQueue queue = PlaybackQueue();
  final Map<String, Track> _byId = {};

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _indexSub;
  var _loadGeneration = 0;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;

  Track? get currentTrack {
    final id = queue.currentId;
    if (id == null) return null;
    return _byId[id];
  }

  PlaybackRepeat get repeat => queue.repeat;

  Future<void> init() async {
    if (!kIsWeb) {
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
      } catch (_) {}
    }
    _stateSub = _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    });
    _positionSub = _player.positionStream.listen((value) {
      position = value;
      notifyListeners();
    });
    _durationSub = _player.durationStream.listen((value) {
      duration = value ?? Duration.zero;
      notifyListeners();
    });
    _indexSub = _player.currentIndexStream.listen((index) {
      if (index == null || index == queue.index) return;
      if (index >= 0 && index < queue.trackIds.length) {
        queue.index = index;
        notifyListeners();
      }
    });
  }

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    for (final track in tracks) {
      _byId[track.id] = track;
    }
    queue.replace(tracks.map((track) => track.id).toList(), startIndex: startIndex);
    await _loadQueue(autoPlay: true);
  }

  Future<void> play() async {
    if (queue.isEmpty) return;
    if (_player.audioSource == null) {
      await _loadQueue(autoPlay: true);
      return;
    }
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    position = Duration.zero;
    isPlaying = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
      return;
    }
    if (queue.repeat == PlaybackRepeat.all && queue.trackIds.isNotEmpty) {
      await _player.seek(Duration.zero, index: 0);
      await _player.play();
      return;
    }
    await stop();
  }

  Future<void> previous() async {
    if (position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
      return;
    }
    if (queue.repeat == PlaybackRepeat.all && queue.trackIds.isNotEmpty) {
      await _player.seek(Duration.zero, index: queue.trackIds.length - 1);
      await _player.play();
    }
  }

  Future<void> seek(Duration value) => _player.seek(value);

  void cycleRepeat() {
    queue.nextRepeat();
    unawaited(_player.setLoopMode(_loopMode()));
    notifyListeners();
  }

  LoopMode _loopMode() {
    switch (queue.repeat) {
      case PlaybackRepeat.off:
        return LoopMode.off;
      case PlaybackRepeat.all:
        return LoopMode.all;
      case PlaybackRepeat.one:
        return LoopMode.one;
    }
  }

  Future<void> _loadQueue({required bool autoPlay}) async {
    if (queue.isEmpty) return;
    final generation = ++_loadGeneration;
    isLoading = true;
    notifyListeners();
    try {
      await _player.stop();
      final ids = List<String>.of(queue.trackIds);
      final sources = <AudioSource>[];
      for (final id in ids) {
        final track = _byId[id];
        if (track == null) continue;
        sources.add(
          AudioSource.uri(
            Uri.parse(track.audioUrl),
            tag: '${track.id}:${track.audioUrl}',
          ),
        );
      }
      if (sources.isEmpty || generation != _loadGeneration) return;
      await _player.setAudioSources(
        sources,
        initialIndex: queue.index.clamp(0, sources.length - 1),
        initialPosition: Duration.zero,
      );
      await _player.setLoopMode(_loopMode());
      if (generation != _loadGeneration) return;
      if (autoPlay) await _player.play();
    } catch (_) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    unawaited(_stateSub?.cancel());
    unawaited(_positionSub?.cancel());
    unawaited(_durationSub?.cancel());
    unawaited(_indexSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
