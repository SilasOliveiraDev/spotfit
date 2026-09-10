import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/core/workout_types.dart';
import 'package:spotfit/models/track.dart';
import 'package:spotfit/state/catalog_controller.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _title = TextEditingController();
  String _type = 'cardio';
  final _selected = <String>{};

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome à playlist, tipo Cardio Manhã.')),
      );
      return;
    }
    final catalog = context.read<CatalogController>();
    final tracks = catalog.tracks.where((track) => _selected.contains(track.id)).toList();
    await catalog.createPlaylist(
      title: title,
      workoutType: _type,
      selected: tracks,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nova playlist')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: 'Nome da playlist',
              hintText: 'Ex.: Cardio Manhã',
              helperText: 'Escreva o nome e depois escolha as faixas',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Foco do treino', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in workoutTypes)
                ChoiceChip(
                  label: Text('${type.emoji} ${type.label}'),
                  selected: _type == type.id,
                  selectedColor: SpotFitColors.lime,
                  labelStyle: TextStyle(
                    color: _type == type.id ? Colors.black : SpotFitColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _type = type.id),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Faixas (opcional)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...catalog.tracks.map((Track track) {
            final checked = _selected.contains(track.id);
            return CheckboxListTile(
              value: checked,
              activeColor: SpotFitColors.lime,
              title: Text(track.title),
              subtitle: Text(track.artist),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selected.add(track.id);
                  } else {
                    _selected.remove(track.id);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Criar playlist')),
        ],
      ),
    );
  }
}
