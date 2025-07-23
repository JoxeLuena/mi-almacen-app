import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/usuarios_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'setup_screen.dart';

// 🛡️ WRAPPER: Gestión de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _needsSetup = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // 🔍 FUNCIÓN: Verificar estado de autenticación y setup
  Future<void> _checkAuthStatus() async {
    try {
      // Verificar si hay token válido primero
      final tokenValido = await UsuariosService.verificarToken();

      if (tokenValido) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        return;
      }

      // Si no hay token, verificar si necesita setup inicial
      // Intentar obtener usuarios (esto fallará si no hay usuarios)
      try {
        final usuarios = await UsuariosService.obtenerUsuarios();
        // Si llegamos aquí pero no hay usuarios, necesita setup
        if (usuarios.isEmpty) {
          setState(() {
            _needsSetup = true;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        // Error al obtener usuarios - probablemente por falta de auth
        // Verificar si es error de setup o de login
        if (e.toString().contains('401') || e.toString().contains('Token')) {
          // Error de autenticación - necesita login
          setState(() {
            _needsSetup = false;
            _isAuthenticated = false;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isAuthenticated = false;
        _needsSetup = false;
        _isLoading = false;
      });
    } catch (e) {
      // Error general - asumir que necesita login
      setState(() {
        _isAuthenticated = false;
        _needsSetup = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Pantalla de carga mientras verifica autenticación
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade900,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  'MOLINCAR TÉCNICA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cargando sistema...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🚀 Mostrar setup si no hay usuarios
    if (_needsSetup) {
      return const SetupScreen();
    }

    // 🔐 Mostrar login si no está autenticado
    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    // 🏠 Mostrar dashboard si está autenticado
    return const DashboardScreen();
  }
}
