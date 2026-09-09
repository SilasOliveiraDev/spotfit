import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/core/workout_types.dart';
import 'package:spotfit/models/playlist.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/cover_image.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final live = catalog.playlists.firstWhere(
      (item) => item.id == playlist.id,
      orElse: () => playlist,
    );
    final type = workoutById(live.workoutType);

    return Scaffold(
      appBar: AppBar(
        title: Text(live.title),
        actions: [
          if (!live.isOfficial)
            IconButton(
              tooltip: 'Compartilhar (em breve)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Compartilhar playlists com a galera do treino vem na próxima versão. O campo is_public já existe no banco.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.ios_share_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Center(child: CoverImage(url: live.coverUrl, size: 220, radius: 20)),
          const SizedBox(height: 16),
          Text(live.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          Text(
            '${type.emoji} ${type.label} · ${live.tracks.length} faixas',
            style: const TextStyle(color: SpotFitColors.muted),
          ),
          if (live.description != null) ...[
            const SizedBox(height: 8),
            Text(live.description!, style: const TextStyle(color: SpotFitColors.muted)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: live.tracks.isEmpty
                ? null
                : () => context.read<PlayerController>().playTracks(live.tracks),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Tocar treino'),
          ),
          const SizedBox(height: 12),
          ...live.tracks.map(
            (track) => TrackTile(track: track, queue: live.tracks),
          ),
        ],
      ),
    );
  }
}
