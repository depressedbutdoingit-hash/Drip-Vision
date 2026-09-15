import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../views/widgets/galaxy_background.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 100, intensity: 0.4),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    DripTheme.cosmicTeal.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                                border: Border.all(
                                  color: DripTheme.cosmicTeal.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.movie_creation,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'DRIPVISION',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                letterSpacing: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'POCKET FILM STUDIO',
                              style: theme.textTheme.bodySmall?.copyWith(
                                letterSpacing: 6,
                                color: DripTheme.cosmicTeal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (!authState.isLogin) {
                                    ref.read(authScreenProvider.notifier).toggleMode();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: authState.isLogin
                                      ? DripTheme.cosmicTeal.withOpacity(0.2)
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                        color: authState.isLogin
                                          ? DripTheme.cosmicTeal
                                          : Colors.white40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (authState.isLogin) {
                                    ref.read(authScreenProvider.notifier).toggleMode();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !authState.isLogin
                                      ? DripTheme.cosmicTeal.withOpacity(0.2)
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'CREATE ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                        color: !authState.isLogin
                                          ? DripTheme.cosmicTeal
                                          : Colors.white40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _emailController,
                        label: 'EMAIL',
                        hint: 'director@dripvision.app',
                        icon: Icons.email_outlined,
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

                      if (!authState.isLogin) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmController,
                          label: 'CONFIRM PASSWORD',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                      ],

                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            authState.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DripTheme.cosmicTeal,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 12,
                            shadowColor: DripTheme.cosmicTeal.withOpacity(0.4),
                          ),
                          child: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                authState.isLogin ? 'ENTER STUDIO' : 'CREATE ACCOUNT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authScreenProvider.notifier).anonymousSignIn(),
                          child: Text(
                            'SKIP FOR NOW →',
                            style: TextStyle(
                              color: Colors.white30,
                              letterSpacing: 2,
                              fontSize: 12,
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
        ],
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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 3,
            color: DripTheme.cosmicTeal.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white20),
            prefixIcon: Icon(icon, color: Colors.white30, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DripTheme.cosmicTeal),
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
