import 'package:flutter/material.dart';
import '../backend/fastapi_backend_client.dart';
import '../features/auth/login_screen.dart';
import '../features/shell/main_shell.dart';
import '../state/app_state.dart';
import 'theme.dart';

class RiskToActionApp extends StatefulWidget {
  const RiskToActionApp({super.key});
  @override
  State<RiskToActionApp> createState() => _RiskToActionAppState();
}
class _RiskToActionAppState extends State<RiskToActionApp> {
  late final AppState _appState;
  // Requires a real login (or the explicit "Continue as Demo" button) before
  // reaching the app - previously defaulted to true, which meant M3's auth
  // check was never actually exercised and no request ever carried a token.
  bool _isAuthenticated = false;
  @override
  void initState() {
    super.initState();
    // Use real M3 FastAPI backend with automatic fallback to MockBackendClient
    // when the backend is offline (handles network errors gracefully).
    _appState = AppState(
      backendClient: FastApiBackendClient(
        baseUrl: 'http://localhost:8000/api/v1',
      ),
    );
  }
  void _handleLogout() {
    final client = _appState.backendClient;
    if (client is FastApiBackendClient) {
      client.logout();
    }
    setState(() => _isAuthenticated = false);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terra Sense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isAuthenticated
          ? MainShell(
              appState: _appState,
              onLogout: _handleLogout,
            )
          : LoginScreen(
              appState: _appState,
              onLoginSuccess: () => setState(() => _isAuthenticated = true),
            ),
    );
  }
}
