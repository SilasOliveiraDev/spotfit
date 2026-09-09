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
  bool _handlingComplete = false;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;

  Track? get currentTrack {
    final id = queue.currentId;
    if (id == null) return null;
    return _byId[id];
  }

  RepeatMode get repeat => queue.repeat;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _stateSub = _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        unawaited(_onComplete());
      }
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
  }

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    for (final track in tracks) {
      _byId[track.id] = track;
    }
    queue.replace(tracks.map((track) => track.id).toList(), startIndex: startIndex);
    await _loadCurrent(autoPlay: true);
  }

  Future<void> play() async {
    if (queue.isEmpty) return;
    if (_player.processingState == ProcessingState.idle) {
      await _loadCurrent(autoPlay: true);
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
    if (queue.moveNext()) {
      await _loadCurrent(autoPlay: true);
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    queue.movePrevious();
    await _loadCurrent(autoPlay: true);
  }

  Future<void> seek(Duration value) => _player.seek(value);

  void cycleRepeat() {
    queue.nextRepeat();
    unawaited(_player.setLoopMode(
      queue.repeat == RepeatMode.one ? LoopMode.one : LoopMode.off,
    ));
    notifyListeners();
  }

  Future<void> _onComplete() async {
    if (_handlingComplete) return;
    _handlingComplete = true;
    try {
      if (queue.repeat == RepeatMode.one) {
        await _player.seek(Duration.zero);
        await _player.play();
        return;
      }
      await next();
    } finally {
      _handlingComplete = false;
    }
  }

  Future<void> _loadCurrent({required bool autoPlay}) async {
    final track = currentTrack;
    if (track == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await _player.setUrl(track.audioUrl);
      await _player.setLoopMode(
        queue.repeat == RepeatMode.one ? LoopMode.one : LoopMode.off,
      );
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
    unawaited(_player.dispose());
    super.dispose();
  }
}
