import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/core/errors/app_failure.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.authInvalid);
      return;
    }
    if (password.length < 8) {
      setState(() => _error = l10n.passwordTooShort);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      ref.read(sessionProvider.notifier).signIn(
        email: user.email ?? email,
        userId: user.id,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AppFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.authInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authResetSent)));
    } on AppFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(authRepositoryProvider);
    if (!repo.isGoogleConfigured) {
      setState(() => _error = l10n.googlePending);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await repo.signInWithGoogle();
      ref.read(sessionProvider.notifier).signIn(
        email: user.email ?? '',
        userId: user.id,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AuthCancelledFailure {
      // Usuario canceló el selector.
    } on AppFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (!configured)
            Text(l10n.authBackendPending, style: Theme.of(context).textTheme.bodyMedium)
          else if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.email),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(labelText: l10n.password),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy || !configured ? null : _reset,
              child: Text(l10n.forgotPassword),
            ),
          ),
          FilledButton(
            onPressed: _busy || !configured ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.signIn),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy || !configured ? null : _google,
            child: Text(l10n.googleSignIn),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.register),
            child: Text(l10n.createAccount),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.authInvalid);
      return;
    }
    if (password.length < 8) {
      setState(() => _error = l10n.passwordTooShort);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).signUp(email, password);
      if (!mounted) return;
      if (result.needsEmailConfirmation || result.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authCheckEmail)),
        );
        context.go(AppRoutes.login);
        return;
      }
      ref.read(sessionProvider.notifier).signIn(
        email: result.user!.email ?? email,
        userId: result.user!.id,
      );
      context.go(AppRoutes.home);
    } on AppFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(authRepositoryProvider);
    if (!repo.isGoogleConfigured) {
      setState(() => _error = l10n.googlePending);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await repo.signInWithGoogle();
      ref.read(sessionProvider.notifier).signIn(
        email: user.email ?? '',
        userId: user.id,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AuthCancelledFailure {
      // Usuario canceló el selector.
    } on AppFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (!configured)
            Text(l10n.authBackendPending, style: Theme.of(context).textTheme.bodyMedium)
          else if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.email),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l10n.password),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy || !configured ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.createAccount),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy || !configured ? null : _google,
            child: Text(l10n.googleSignIn),
          ),
        ],
      ),
    );
  }
}
