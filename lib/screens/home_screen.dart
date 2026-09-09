import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/core/workout_types.dart';
import 'package:spotfit/models/playlist.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/screens/playlist_screen.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/cover_image.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final catalog = context.watch<CatalogController>();
    final name = auth.profile?.displayName.split(' ').first ?? 'atleta';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(color: SpotFitColors.muted),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Escolha o foco do treino e aperta o play.',
                  style: TextStyle(color: SpotFitColors.muted),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: workoutTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final type = workoutTypes[index];
                return _WorkoutChip(
                  type: type,
                  onTap: () {
                    final lists = catalog.byWorkout(type.id);
                    if (lists.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistScreen(playlist: lists.first),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Playlists oficiais',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 252,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: catalog.officialPlaylists().length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final playlist = catalog.officialPlaylists()[index];
                return _PlaylistCard(playlist: playlist);
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Catálogo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
          sliver: SliverList.builder(
            itemCount: catalog.tracks.length,
            itemBuilder: (context, index) {
              return TrackTile(
                track: catalog.tracks[index],
                queue: catalog.tracks,
              );
            },
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom treino,';
    if (hour < 18) return 'Bora suar,';
    return 'Sessão noturna,';
  }
}

class _WorkoutChip extends StatelessWidget {
  const _WorkoutChip({required this.type, required this.onTap});

  final WorkoutType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 120,
        decoration: BoxDecoration(
          color: SpotFitColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(type.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: playlist)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
            CoverImage(url: playlist.coverUrl, size: 148, radius: 16),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CircleAvatar(
                    backgroundColor: SpotFitColors.lime,
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                      onPressed: () {
                        context.read<PlayerController>().playTracks(playlist.tracks);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '${playlist.tracks.length} faixas · ${workoutById(playlist.workoutType).label}',
              style: const TextStyle(color: SpotFitColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
