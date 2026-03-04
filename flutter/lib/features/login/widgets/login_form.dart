import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
              labelText: 'Email',
              hintText: 'ton@email.com',
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
              hintText: '••••••••',
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

          // ── Bouton de connexion ────────────────────────────────────────────
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isLoading ? null : _onSubmit,
            child: Opacity(
              opacity: _isLoading ? 0.5 : 1.0,
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 8, top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.foreground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading ? 'Connexion...' : 'Se connecter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.accentForeground,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Mot de passe oublié ────────────────────────────────────────────
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _onForgotPassword,
            child: const Text(
              'Mot de passe oublié ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedForeground,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
