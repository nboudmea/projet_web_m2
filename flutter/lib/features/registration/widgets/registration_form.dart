import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';

/// Formulaire d'inscription isolé — miroir de [RegistrationComponent] Angular.
/// Gère validation (dont correspondance des mots de passe), rôle, loading et erreurs.
class RegistrationForm extends ConsumerStatefulWidget {
  const RegistrationForm({super.key});

  @override
  ConsumerState<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _role = 'eleve';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ─── Soumission ───────────────────────────────────────────────────────────

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).register(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _role,
          );
      // La redirection est gérée par GoRouter via le RouterNotifier
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(AuthService.getErrorMessage(e.code));
    } catch (_) {
      if (mounted) _showError('Une erreur est survenue. Réessaie.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: 16),

          // ── Confirmation mot de passe ──────────────────────────────────────
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSubmit(),
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'La confirmation est requise.';
              }
              if (v != _passwordCtrl.text) {
                return 'Les mots de passe ne correspondent pas.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // ── Sélection du rôle ──────────────────────────────────────────────
          const Text(
            'Je suis',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          _RoleSelector(
            value: _role,
            onChanged: (v) => setState(() => _role = v),
          ),
          const SizedBox(height: 24),

          // ── Bouton d'inscription ───────────────────────────────────────────
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
                      _isLoading ? 'Création...' : 'Créer mon compte',
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
        ],
      ),
    );
  }
}

// ─── Widget sélecteur de rôle ─────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleTile(
            label: 'Élève',
            selected: value == 'eleve',
            onTap: () => onChanged('eleve'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleTile(
            label: 'Bénévole',
            selected: value == 'benevole',
            onTap: () => onChanged('benevole'),
          ),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.foreground : AppColors.input;
    final bgColor =
        selected ? const Color(0xFFF0F0F0) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor, width: selected ? 1.5 : 1.5),
          color: bgColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
