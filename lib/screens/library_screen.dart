import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/core/workout_types.dart';
import 'package:spotfit/models/playlist.dart';
import 'package:spotfit/screens/create_playlist_screen.dart';
import 'package:spotfit/screens/playlist_screen.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/cover_image.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sua biblioteca',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Nova playlist',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const TabBar(
            indicatorColor: SpotFitColors.lime,
            labelColor: SpotFitColors.lime,
            unselectedLabelColor: SpotFitColors.muted,
            tabs: [
              Tab(text: 'Playlists'),
              Tab(text: 'Favoritos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PlaylistsTab(catalog: catalog),
                catalog.favorites().isEmpty
                    ? const Center(
                        child: Text(
                          'Favorite faixas para montar o treino rápido.',
                          style: TextStyle(color: SpotFitColors.muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: catalog.favorites().length,
                        itemBuilder: (context, index) {
                          final tracks = catalog.favorites();
                          return TrackTile(track: tracks[index], queue: tracks);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab({required this.catalog});

  final CatalogController catalog;

  @override
  Widget build(BuildContext context) {
    final mine = catalog.userPlaylists();
    final official = catalog.officialPlaylists();
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 120),
      children: [
        ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SpotFitColors.lime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Colors.black),
          ),
          title: const Text('Criar playlist'),
          subtitle: const Text('Cardio, Muscle, HIIT...'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
          ),
        ),
        if (mine.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Minhas listas', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ...mine.map((playlist) => _row(context, playlist, canDelete: true)),
        ],
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Oficiais SpotFit', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        ...official.map((playlist) => _row(context, playlist, canDelete: false)),
      ],
    );
  }

  Widget _row(BuildContext context, Playlist playlist, {required bool canDelete}) {
    return ListTile(
      leading: CoverImage(url: playlist.coverUrl, size: 56, radius: 8),
      title: Text(playlist.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        '${workoutById(playlist.workoutType).label} · ${playlist.tracks.length} faixas'
        '${playlist.isPublic ? ' · compartilhada' : ''}',
      ),
      trailing: canDelete
          ? IconButton(
              tooltip: 'Excluir',
              onPressed: () => catalog.deletePlaylist(playlist.id),
              icon: const Icon(Icons.delete_outline_rounded),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: playlist)),
      ),
    );
  }
}
