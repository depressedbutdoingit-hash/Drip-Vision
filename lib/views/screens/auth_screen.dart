import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/auth_service.dart';
import '../widgets/drip_button.dart';
import '../../core/auth_providers.dart';
import '../../core/app_providers.dart';

final authScreenProvider = StateNotifierProvider<AuthScreenNotifier, AuthScreenState>((ref) {
  return AuthScreenNotifier(ref.read(authServiceProvider));
});

class AuthScreenState {
  final bool isLoading;
  final bool isLogin;
  final String? error;

  AuthScreenState({
    this.isLoading = false,
    this.isLogin = true,
    this.error,
  });

  AuthScreenState copyWith({
    bool? isLoading,
    bool? isLogin,
    String? error,
  }) {
    return AuthScreenState(
      isLoading: isLoading ?? this.isLoading,
      isLogin: isLogin ?? this.isLogin,
      error: error,
    );
  }
}

class AuthScreenNotifier extends StateNotifier<AuthScreenState> {
  final AuthService _auth;

  AuthScreenNotifier(this._auth) : super(AuthScreenState());

  void toggleMode() {
    state = state.copyWith(isLogin: !state.isLogin, error: null);
  }

  Future<void> submit(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.isLogin) {
        await _auth.signInWithEmail(email, password);
      } else {
        await _auth.registerWithEmail(email, password);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> anonymousSignIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns null on success, or an error message.
  Future<String?> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _auth.sendPasswordReset(email);
      state = state.copyWith(isLoading: false, error: null);
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? e.code;
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    } catch (e) {
      final msg = e.toString();
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }
    final err = await ref.read(authScreenProvider.notifier).resetPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null
              ? 'Password reset email sent to $email'
              : err,
        ),
      ),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authScreenProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Center(
                    child: Column(
                      children: [
                        Text('DRIPVISION', style: DripTheme.brandMark),
                        SizedBox(height: 10),
                        Text('CINEMATIC STUDIO', style: DripTheme.overline),
                        SizedBox(height: 12),
                        Text(
                          'An AI filmmaking studio that remembers your universe.',
                          textAlign: TextAlign.center,
                          style: DripTheme.meta,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Mode switch — quiet segmented control
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: DripTheme.surface,
                      borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                      border: Border.all(color: DripTheme.hairline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _modeTab(
                            label: 'SIGN IN',
                            selected: authState.isLogin,
                            onTap: () {
                              if (!authState.isLogin) {
                                ref.read(authScreenProvider.notifier).toggleMode();
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: _modeTab(
                            label: 'REGISTER',
                            selected: !authState.isLogin,
                            onTap: () {
                              if (authState.isLogin) {
                                ref.read(authScreenProvider.notifier).toggleMode();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildTextField(
                    controller: _emailController,
                    label: 'EMAIL',
                    hint: 'you@studio.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'PASSWORD',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  if (authState.isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => _forgotPassword(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'FORGOT PASSWORD',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            color: DripTheme.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!authState.isLogin) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmController,
                      label: 'CONFIRM',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                  ],

                  if (authState.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      authState.error!,
                      style: const TextStyle(
                        color: Color(0xFFE8A0A0),
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  DripButton(
                    width: double.infinity,
                    height: 52,
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: DripTheme.voidBlack,
                            ),
                          )
                        : Text(authState.isLogin ? 'ENTER STUDIO' : 'CREATE ACCOUNT'),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref.read(authScreenProvider.notifier).anonymousSignIn(),
                      child: const Text(
                        'CONTINUE AS GUEST',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.6,
                          color: DripTheme.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected ? DripTheme.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(DripTheme.radiusSm),
          border: selected
              ? Border.all(color: DripTheme.hairlineStrong)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
            color: selected ? DripTheme.warmWhite : DripTheme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DripTheme.overline),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: DripTheme.warmWhite, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: DripTheme.muted),
            prefixIcon: Icon(icon, color: DripTheme.muted, size: 20),
            filled: true,
            fillColor: DripTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DripTheme.radiusMd),
              borderSide: const BorderSide(color: DripTheme.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DripTheme.radiusMd),
              borderSide: const BorderSide(color: DripTheme.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DripTheme.radiusMd),
              borderSide: const BorderSide(color: DripTheme.cosmicTeal),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (!ref.read(authScreenProvider).isLogin) {
      final confirm = _confirmController.text.trim();
      if (password != confirm) {
        return;
      }
    }

    ref.read(authScreenProvider.notifier).submit(email, password);
  }
}
