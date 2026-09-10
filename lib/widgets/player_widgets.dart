import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/models/track.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/player/playback_queue.dart';
import 'package:spotfit/screens/now_playing_screen.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/cover_image.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final track = player.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return Material(
      color: SpotFitColors.surfaceHigh,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: player.duration.inMilliseconds == 0
                  ? 0
                  : player.position.inMilliseconds / player.duration.inMilliseconds,
              minHeight: 2,
              color: SpotFitColors.lime,
              backgroundColor: Colors.white10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  CoverImage(url: track.coverUrl, size: 48, radius: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SpotFitColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Anterior',
                    onPressed: player.previous,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  IconButton(
                    tooltip: player.isPlaying ? 'Pausar' : 'Tocar',
                    onPressed: player.togglePlayPause,
                    icon: Icon(
                      player.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 36,
                      color: SpotFitColors.lime,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Parar',
                    onPressed: player.stop,
                    icon: const Icon(Icons.stop_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    this.queue,
    this.trailing,
  });

  final Track track;
  final List<Track>? queue;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final catalog = context.watch<CatalogController>();
    final active = player.currentTrack?.id == track.id;
    final liked = catalog.favoriteIds.contains(track.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CoverImage(url: track.coverUrl, size: 52, radius: 8),
      title: Text(
        track.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: active ? SpotFitColors.lime : SpotFitColors.text,
        ),
      ),
      subtitle: Text(
        '${track.artist} · ${track.bpm ?? '--'} BPM · ${track.durationLabel}',
        style: const TextStyle(color: SpotFitColors.muted, fontSize: 12),
      ),
      trailing: trailing ??
          IconButton(
            tooltip: liked ? 'Remover dos favoritos' : 'Favoritar',
            onPressed: () => catalog.toggleFavorite(track),
            icon: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: liked ? SpotFitColors.coral : SpotFitColors.muted,
            ),
          ),
      onTap: () {
        final list = queue ?? catalog.tracks;
        final index = list.indexWhere((item) => item.id == track.id);
        context.read<PlayerController>().playTracks(list, startIndex: index < 0 ? 0 : index);
      },
    );
  }
}

class RepeatIcon extends StatelessWidget {
  const RepeatIcon({super.key, required this.mode});

  final PlaybackRepeat mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PlaybackRepeat.off:
        return const Icon(Icons.repeat_rounded, color: SpotFitColors.muted);
      case PlaybackRepeat.all:
        return const Icon(Icons.repeat_rounded, color: SpotFitColors.lime);
      case PlaybackRepeat.one:
        return const Icon(Icons.repeat_one_rounded, color: SpotFitColors.lime);
    }
  }
}
