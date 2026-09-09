import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/screens/auth_screen.dart';
import 'package:spotfit/screens/shell_screen.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';

class SpotFitApp extends StatelessWidget {
  const SpotFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotFit',
      debugShowCheckedModeBanner: false,
      theme: buildSpotFitTheme(),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isSignedIn) {
      return const AuthScreen();
    }

    final catalog = context.read<CatalogController>();
    catalog.rebind(
      userId: auth.profile!.id,
      client: auth.usesSupabase ? auth.client : null,
    );
    return const ShellScreen();
  }
}
