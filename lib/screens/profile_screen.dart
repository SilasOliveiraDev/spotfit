import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/config.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final catalog = context.watch<CatalogController>();
    final profile = auth.profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: SpotFitColors.lime,
          child: Icon(Icons.person_rounded, color: Colors.black, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          profile?.displayName ?? 'Atleta',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        Text(
          profile?.email ?? (auth.demoGuest ? 'modo demo' : ''),
          textAlign: TextAlign.center,
          style: const TextStyle(color: SpotFitColors.muted),
        ),
        const SizedBox(height: 24),
        _stat('Favoritos', '${catalog.favoriteIds.length}'),
        _stat('Minhas playlists', '${catalog.userPlaylists().length}'),
        _stat(
          'Backend',
          AppConfig.hasSupabase ? 'Supabase conectado' : 'Demo local',
        ),
        const SizedBox(height: 16),
        const Text(
          'Compartilhe uma playlist só com quem tiver o link (spotfit://playlist/…). Não existe feed público.',
          style: TextStyle(color: SpotFitColors.muted),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: auth.signOut,
          child: const Text('Sair'),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value, style: const TextStyle(color: SpotFitColors.lime, fontWeight: FontWeight.w700)),
    );
  }
}
