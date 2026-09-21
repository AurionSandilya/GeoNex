import 'package:flutter/material.dart';
import '../../backend/fastapi_backend_client.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.appState,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'official@arunachal.gov.in');
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.authority;
  bool _isLoggingIn = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final client = widget.appState.backendClient;
    if (client is! FastApiBackendClient) {
      // No real backend wired up (e.g. tests) - fall back to role switch only.
      widget.appState.switchUserRole(_selectedRole);
      widget.onLoginSuccess();
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    final ok = await client.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoggingIn = false);

    if (ok) {
      widget.appState.switchUserRole(_selectedRole);
      widget.onLoginSuccess();
    } else {
      setState(() => _loginError = 'Incorrect email or password, or the server is unreachable.');
    }
  }

  /// Explicit offline/demo path - does NOT authenticate against M3, so it
  /// must never be wired to any screen that submits real data upstream.
  void _handleDemoLogin() {
    widget.appState.switchUserRole(_selectedRole);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo matching wireframe
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPastel,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title matching wireframe
                const Center(
                  child: Text(
                    'Terra Sense',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Landslide Risk Monitoring & Response Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Card Container with Pastel styling
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email / Phone',
                          prefixIcon: Icon(Icons.badge_outlined, size: 18),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoggingIn ? null : _handleLogin,
                        child: _isLoggingIn
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Login'),
                      ),
                      if (_loginError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _loginError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Continue as Demo Button
                      OutlinedButton(
                        onPressed: _isLoggingIn ? null : _handleDemoLogin,
                        child: const Text('Continue as Demo'),
                      ),
                      const SizedBox(height: 20),

                      // Role Label & Selection matching wireframe (Role: Authority | Field Officer | Citizen)
                      const Text(
                        'Select Role',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            _buildRoleOption('Authority', UserRole.authority),
                            _buildRoleOption('Field Officer', UserRole.fieldOfficer),
                            _buildRoleOption('Citizen', UserRole.citizen),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Footer
                const Center(
                  child: Text(
                    'National Disaster Intelligence Network • North-East India',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String label, UserRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
  setState(() {
    _selectedRole = role;
  });
},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
