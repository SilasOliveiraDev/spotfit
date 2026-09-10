import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfit/app.dart';
import 'package:spotfit/core/config.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseClient? supabase;
  try {
    if (AppConfig.hasSupabase) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      ).timeout(const Duration(seconds: 12));
      supabase = Supabase.instance.client;
    }
  } catch (_) {
    supabase = null;
  }

  final auth = AuthController(client: supabase);
  final player = PlayerController();
  final catalog = CatalogController(userId: 'demo-user');
  try {
    await auth.bootstrap().timeout(const Duration(seconds: 8));
  } catch (_) {}
  unawaited(player.init());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: player),
        ChangeNotifierProvider.value(value: catalog),
      ],
      child: const SpotFitApp(),
    ),
  );
}
