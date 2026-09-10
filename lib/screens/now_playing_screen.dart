import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/player/playback_queue.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/cover_image.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final catalog = context.watch<CatalogController>();
    final track = player.currentTrack;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Nada tocando agora.')),
      );
    }

    final liked = catalog.favoriteIds.contains(track.id);
    final maxMs = player.duration.inMilliseconds <= 0
        ? 1.0
        : player.duration.inMilliseconds.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tocando agora'),
        actions: [
          IconButton(
            tooltip: liked ? 'Desfavoritar' : 'Favoritar',
            onPressed: () => catalog.toggleFavorite(track),
            icon: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: liked ? SpotFitColors.coral : null,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            const Spacer(),
            CoverImage(url: track.coverUrl, size: 280, radius: 24),
            const SizedBox(height: 28),
            Text(
              track.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${track.artist} · ${track.bpm ?? '--'} BPM',
              style: const TextStyle(color: SpotFitColors.muted),
            ),
            const Spacer(),
            Slider(
              value: player.position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble(),
              max: maxMs,
              activeColor: SpotFitColors.lime,
              onChanged: (value) => player.seek(Duration(milliseconds: value.round())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(player.position), style: const TextStyle(color: SpotFitColors.muted)),
                Text(_fmt(player.duration), style: const TextStyle(color: SpotFitColors.muted)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: _repeatLabel(player.repeat),
                  onPressed: player.cycleRepeat,
                  icon: RepeatIcon(mode: player.repeat),
                ),
                IconButton(
                  tooltip: 'Anterior',
                  iconSize: 36,
                  onPressed: player.previous,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                FilledButton(
                  onPressed: player.togglePlayPause,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    minimumSize: const Size(72, 72),
                  ),
                  child: Icon(
                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 36,
                  ),
                ),
                IconButton(
                  tooltip: 'Próxima',
                  iconSize: 36,
                  onPressed: player.next,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
                IconButton(
                  tooltip: 'Parar',
                  onPressed: player.stop,
                  icon: const Icon(Icons.stop_circle_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration value) {
    final m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _repeatLabel(PlaybackRepeat mode) {
    switch (mode) {
      case PlaybackRepeat.off:
        return 'Repeat desligado';
      case PlaybackRepeat.all:
        return 'Repeat da playlist';
      case PlaybackRepeat.one:
        return 'Repeat da faixa';
    }
  }
}
