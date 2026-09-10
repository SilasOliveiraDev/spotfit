import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/share_links.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/screens/auth_screen.dart';
import 'package:spotfit/screens/playlist_screen.dart';
import 'package:spotfit/screens/shell_screen.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';

final spotFitNavigatorKey = GlobalKey<NavigatorState>();

class SpotFitApp extends StatefulWidget {
  const SpotFitApp({super.key});

  @override
  State<SpotFitApp> createState() => _SpotFitAppState();
}

class _SpotFitAppState extends State<SpotFitApp> {
  StreamSubscription<Uri>? _linkSub;
  String? _pendingToken;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    try {
      final links = AppLinks();
      _linkSub = links.uriLinkStream.listen(_handleUri);
      unawaited(links.getInitialLink().then((uri) {
        if (uri != null) _handleUri(uri);
      }));
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_linkSub?.cancel());
    super.dispose();
  }

  void _handleUri(Uri uri) {
    final token = parseShareToken(uri);
    if (token == null || token.isEmpty) return;
    _openShared(token);
  }

  Future<void> _openShared(String token) async {
    final auth = context.read<AuthController>();
    if (!auth.isSignedIn) {
      _pendingToken = token;
      return;
    }
    final catalog = context.read<CatalogController>();
    final playlist = await catalog.playlistFromShareToken(token);
    final nav = spotFitNavigatorKey.currentState;
    if (playlist == null || nav == null) return;
    await nav.push(MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: playlist)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: spotFitNavigatorKey,
      title: 'SpotFit',
      debugShowCheckedModeBanner: false,
      theme: buildSpotFitTheme(),
      home: _Root(
        onSignedIn: () {
          final token = _pendingToken;
          if (token == null) return;
          _pendingToken = null;
          unawaited(_openShared(token));
        },
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root({required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  var _openedPending = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isSignedIn) {
      _openedPending = false;
      return const AuthScreen();
    }

    final catalog = context.read<CatalogController>();
    catalog.rebind(
      userId: auth.profile!.id,
      client: auth.usesSupabase ? auth.client : null,
    );
    if (!_openedPending) {
      _openedPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSignedIn());
    }
    return const ShellScreen();
  }
}
