import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfit/core/config.dart';
import 'package:spotfit/models/profile.dart';

class AuthController extends ChangeNotifier {
  AuthController({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  static const _demoKey = 'spotfit_demo_guest';

  Profile? profile;
  bool demoGuest = false;
  bool ready = false;
  String? errorMessage;

  bool get isSignedIn => profile != null;
  bool get usesSupabase => AppConfig.hasSupabase && _client != null;
  SupabaseClient? get client => _client;

  Future<void> bootstrap() async {
    if (usesSupabase) {
      _client!.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session == null) {
          profile = null;
          notifyListeners();
        } else {
          unawaitedLoadProfile(session.user);
        }
      });
      final session = _client.auth.currentSession;
      if (session != null) {
        await _loadProfile(session.user);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      demoGuest = prefs.getBool(_demoKey) ?? false;
      if (demoGuest) {
        profile = const Profile(id: 'demo-user', displayName: 'Atleta Demo');
      }
    }
    ready = true;
    notifyListeners();
  }

  void unawaitedLoadProfile(User user) {
    _loadProfile(user);
  }

  Future<void> _loadProfile(User user) async {
    Map<String, dynamic>? row;
    try {
      row = await _client!
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (_) {
      row = null;
    }
    profile = Profile(
      id: user.id,
      displayName: (row?['display_name'] as String?) ??
          (user.email?.split('@').first ?? 'Atleta'),
      fitnessFocus: row?['fitness_focus'] as String?,
      email: user.email,
    );
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    if (!usesSupabase) {
      errorMessage = 'Configure o Supabase para entrar com e-mail.';
      notifyListeners();
      return false;
    }
    try {
      errorMessage = null;
      await _client!.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    if (!usesSupabase) {
      errorMessage = 'Configure o Supabase para criar conta.';
      notifyListeners();
      return false;
    }
    try {
      errorMessage = null;
      await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> enterDemo() async {
    demoGuest = true;
    profile = const Profile(id: 'demo-user', displayName: 'Atleta Demo');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoKey, true);
    notifyListeners();
  }

  Future<void> signOut() async {
    if (usesSupabase) {
      await _client!.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoKey, false);
    demoGuest = false;
    profile = null;
    notifyListeners();
  }
}
