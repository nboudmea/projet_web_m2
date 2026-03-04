import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';

/// Formulaire de connexion isolé — miroir du formulaire Angular [LoginComponent].
/// Gère validation, loading, erreurs et forgot-password.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Soumission du formulaire ─────────────────────────────────────────────

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authServiceProvider)
          .login(_emailCtrl.text.trim(), _passwordCtrl.text);
      // La redirection est gérée par GoRouter via le RouterNotifier
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(AuthService.getErrorMessage(e.code));
      }
    } catch (_) {
      if (mounted) {
        _showError('Une erreur est survenue. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Mot de passe oublié ──────────────────────────────────────────────────

  Future<void> _onForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Saisis ton email avant de demander une réinitialisation.');
      return;
    }
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de réinitialisation envoyé !'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.getErrorMessage(e.code));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Email ──────────────────────────────────────────────────────────
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              hintText: 'exemple@mail.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'L\'email est requis.';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(v)) return 'Format d\'email invalide.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Mot de passe ───────────────────────────────────────────────────
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSubmit(),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Le mot de passe est requis.';
              if (v.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // ── Mot de passe oublié ────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _onForgotPassword,
              child: const Text('Mot de passe oublié ?'),
            ),
          ),
          const SizedBox(height: 16),

          // ── Bouton de connexion ────────────────────────────────────────────
          FilledButton(
            onPressed: _isLoading ? null : _onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF4C6FFF),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
