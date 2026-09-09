import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/screens/playlist_screen.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final results = catalog.search(_query);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buscar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Música, artista ou treino (cardio, hiit...)',
            ),
          ),
          const SizedBox(height: 16),
          if (_query.isEmpty)
            Expanded(
              child: ListView(
                children: [
                  const Text('Playlists', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...catalog.playlists.map(
                    (playlist) => ListTile(
                      title: Text(playlist.title),
                      subtitle: Text(playlist.workoutType),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlaylistScreen(playlist: playlist),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada encontrado para esse treino.',
                        style: TextStyle(color: SpotFitColors.muted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) => TrackTile(
                        track: results[index],
                        queue: results,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
