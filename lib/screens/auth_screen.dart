import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotfit/core/theme.dart';
import 'package:spotfit/state/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = context.read<AuthController>();
    final ok = _register
        ? await auth.signUp(_name.text.trim(), _email.text.trim(), _password.text)
        : await auth.signIn(_email.text.trim(), _password.text);
    if (mounted) setState(() => _busy = false);
    if (!ok && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            const Text('🏃 SpotFit', style: TextStyle(fontSize: 18, color: SpotFitColors.lime)),
            const SizedBox(height: 12),
            const Text(
              'A trilha sonora do seu treino.',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Playlists de cardio, músculo e HIIT — play, pause, repeat e favoritos.',
              style: TextStyle(color: SpotFitColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Form(
              key: _form,
              child: Column(
                children: [
                  if (_register)
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) =>
                          _register && (value == null || value.trim().isEmpty)
                              ? 'Informe seu nome'
                              : null,
                    ),
                  if (_register) const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) =>
                        value != null && value.contains('@') ? null : 'E-mail inválido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: (value) =>
                        value != null && value.length >= 6 ? null : 'Mínimo 6 caracteres',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_register ? 'Criar conta' : 'Entrar'),
            ),
            TextButton(
              onPressed: () => setState(() => _register = !_register),
              child: Text(
                _register ? 'Já tenho conta' : 'Criar conta com e-mail',
                style: const TextStyle(color: SpotFitColors.lime),
              ),
            ),
            const SizedBox(height: 8),
            if (!auth.usesSupabase) ...[
              OutlinedButton(
                onPressed: auth.enterDemo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SpotFitColors.text,
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Entrar no modo treino (demo)'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sem backend neste build — o modo demo usa o catálogo local.',
                style: TextStyle(color: SpotFitColors.muted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
