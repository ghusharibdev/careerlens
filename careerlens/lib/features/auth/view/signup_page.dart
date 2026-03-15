import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _vm = AuthViewModel();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() { _loading = true; _error = null; });
    final err = await _vm.signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _nameCtrl.text.trim(),
    );
    if (mounted) {
      setState(() { _loading = false; _error = err; });
      if (err == null) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                ),
                child: const Icon(Icons.work_outline_rounded, color: AppTheme.accent, size: 24),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              Text('Create account', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28))
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text('Start tracking your job search.', style: Theme.of(context).textTheme.bodyMedium)
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline, color: AppTheme.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(label: 'Create Account', onTap: _signup, loading: _loading),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
