import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfit/app.dart';
import 'package:spotfit/core/config.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseClient? supabase;
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
  }

  final auth = AuthController(client: supabase);
  final player = PlayerController();
  await Future.wait([auth.bootstrap(), player.init()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: player),
      ],
      child: const SpotFitApp(),
    ),
  );
}
