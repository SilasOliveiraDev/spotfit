import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/screens/home_screen.dart';
import 'package:spotfit/screens/library_screen.dart';
import 'package:spotfit/screens/profile_screen.dart';
import 'package:spotfit/screens/search_screen.dart';
import 'package:spotfit/state/catalog_controller.dart';
import 'package:spotfit/widgets/player_widgets.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CatalogController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final pages = const [
      HomeScreen(),
      SearchScreen(),
      LibraryScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: catalog.loading && catalog.tracks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: SpotFitColors.lime),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded, color: SpotFitColors.lime),
                label: 'Buscar',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded, color: SpotFitColors.lime),
                label: 'Biblioteca',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: SpotFitColors.lime),
                label: 'Perfil',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
