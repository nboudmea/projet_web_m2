import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/theme/app_colors.dart';

/// Écran profil utilisateur — miroir de ProfileComponent Angular.
/// Trois sections : infos personnelles, changement d'email, changement de mot de passe.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mon profil',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
      ),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erreur : $e')),
        data: (user) {
          if (user == null) {
            return const Center(
                child: Text('Utilisateur introuvable.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              // ── Avatar ────────────────────────────────────────────────
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.foreground,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          _initials(user.prenom, user.nom),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isBenevole ? 'Bénévole' : 'Élève',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Infos personnelles ───────────────────────────────────────
              _InfoSection(user: user),
              const SizedBox(height: 20),

              // ── Changement d'email ────────────────────────────────────────
              const _EmailSection(),
              const SizedBox(height: 20),

              // ── Changement de mot de passe ────────────────────────────────
              const _PasswordSection(),
            ],
          );
        },
      ),
    );
  }

  String _initials(String prenom, String nom) {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }
}

// ─── Section infos personnelles ───────────────────────────────────────────────

class _InfoSection extends ConsumerStatefulWidget {
  const _InfoSection({required this.user});
  final AppUser user;

  @override
  ConsumerState<_InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends ConsumerState<_InfoSection> {
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;
  bool _saving = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _nomCtrl = TextEditingController(text: widget.user.nom);
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final prenom = _prenomCtrl.text.trim();
    final nom = _nomCtrl.text.trim();
    if (prenom.isEmpty || nom.isEmpty) return;
    setState(() {
      _saving = true;
      _success = false;
      _error = null;
    });
    try {
      await ref
          .read(userServiceProvider)
          .updateProfile(widget.user.id,
              nom: nom, prenom: prenom);
      if (mounted) setState(() => _success = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur lors de la sauvegarde.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informations personnelles',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _FieldRow(
            label: 'Prénom',
            controller: _prenomCtrl,
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Nom',
            controller: _nomCtrl,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            _ErrorText(_error!),
          ],
          if (_success) ...[
            const SizedBox(height: 8),
            const _SuccessText('Profil mis à jour.'),
          ],
          const SizedBox(height: 16),
          _SaveButton(loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

// ─── Section changement d'email ────────────────────────────────────────────────

class _EmailSection extends ConsumerStatefulWidget {
  const _EmailSection();

  @override
  ConsumerState<_EmailSection> createState() => _EmailSectionState();
}

class _EmailSectionState extends ConsumerState<_EmailSection> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _saving = false;
  bool _success = false;
  String? _error;
  bool _obscurePw = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (email.isEmpty || pw.isEmpty) return;
    setState(() {
      _saving = true;
      _success = false;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).reauthenticate(pw);
      await ref.read(authServiceProvider).updateEmail(email);
      if (mounted) {
        setState(() => _success = true);
        _emailCtrl.clear();
        _pwCtrl.clear();
      }
    } catch (e) {
      if (mounted) setState(() => _error = _mapError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _mapError(Object e) {
    final code = (e as dynamic).code as String? ?? '';
    if (code == 'wrong-password' || code == 'invalid-credential') {
      return 'Mot de passe actuel incorrect.';
    }
    if (code == 'email-already-in-use') {
      return 'Adresse email déjà utilisée.';
    }
    if (code == 'invalid-email') return 'Adresse email invalide.';
    if (code == 'requires-recent-login') {
      return 'Session expirée. Reconnectez-vous.';
    }
    return 'Une erreur est survenue.';
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Changer l'adresse email",
      icon: Icons.email_outlined,
      child: Column(
        children: [
          _FieldRow(
            label: 'Nouvelle adresse email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Mot de passe actuel',
            controller: _pwCtrl,
            obscureText: _obscurePw,
            suffix: IconButton(
              icon: Icon(
                _obscurePw
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              onPressed: () =>
                  setState(() => _obscurePw = !_obscurePw),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            _ErrorText(_error!),
          ],
          if (_success) ...[
            const SizedBox(height: 8),
            const _SuccessText(
                'Un email de vérification a été envoyé.'),
          ],
          const SizedBox(height: 16),
          _SaveButton(loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

// ─── Section changement de mot de passe ───────────────────────────────────────

class _PasswordSection extends ConsumerStatefulWidget {
  const _PasswordSection();

  @override
  ConsumerState<_PasswordSection> createState() =>
      _PasswordSectionState();
}

class _PasswordSectionState extends ConsumerState<_PasswordSection> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _saving = false;
  bool _success = false;
  String? _error;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentPwCtrl.text;
    final newPw = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;

    if (newPw != confirm) {
      setState(() =>
          _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (newPw.length < 6) {
      setState(() =>
          _error = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    setState(() {
      _saving = true;
      _success = false;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).reauthenticate(current);
      await ref.read(authServiceProvider).updatePassword(newPw);
      if (mounted) {
        setState(() => _success = true);
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
      }
    } catch (e) {
      if (mounted) setState(() => _error = _mapError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _mapError(Object e) {
    final code = (e as dynamic).code as String? ?? '';
    if (code == 'wrong-password' || code == 'invalid-credential') {
      return 'Mot de passe actuel incorrect.';
    }
    if (code == 'requires-recent-login') {
      return 'Session expirée. Reconnectez-vous.';
    }
    return 'Une erreur est survenue.';
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Changer le mot de passe',
      icon: Icons.lock_outline_rounded,
      child: Column(
        children: [
          _FieldRow(
            label: 'Mot de passe actuel',
            controller: _currentPwCtrl,
            obscureText: _obscureCurrent,
            suffix: IconButton(
              icon: Icon(
                _obscureCurrent
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              onPressed: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Nouveau mot de passe',
            controller: _newPwCtrl,
            obscureText: _obscureNew,
            suffix: IconButton(
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              onPressed: () =>
                  setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Confirmer le mot de passe',
            controller: _confirmPwCtrl,
            obscureText: _obscureConfirm,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              onPressed: () => setState(
                  () => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            _ErrorText(_error!),
          ],
          if (_success) ...[
            const SizedBox(height: 8),
            const _SuccessText('Mot de passe mis à jour.'),
          ],
          const SizedBox(height: 16),
          _SaveButton(loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

// ─── Composants partagés ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.foreground),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton(
      {required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foreground,
          foregroundColor: AppColors.accent,
          padding:
              const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent))
            : const Text('Enregistrer',
                style: TextStyle(
                    fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
          fontSize: 13, color: Colors.red),
    );
  }
}

class _SuccessText extends StatelessWidget {
  const _SuccessText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
          fontSize: 13, color: Colors.green),
    );
  }
}
