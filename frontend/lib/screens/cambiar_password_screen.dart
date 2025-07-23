import 'package:flutter/material.dart';
import '../services/usuarios_service.dart';

// 🔑 PANTALLA: Cambiar contraseña
class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  // 📝 CONTROLADORES: Para los campos de texto
  final TextEditingController _passwordActualController =
      TextEditingController();
  final TextEditingController _passwordNuevoController =
      TextEditingController();
  final TextEditingController _confirmarPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 🔐 ESTADO: Visibilidad de contraseñas
  bool _obscureActual = true;
  bool _obscureNuevo = true;
  bool _obscureConfirmar = true;

  // 🔄 ESTADO: Proceso
  bool _isLoading = false;
  String? _error;
  bool _cambioExitoso = false;

  @override
  void dispose() {
    _passwordActualController.dispose();
    _passwordNuevoController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = UsuariosService.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 INFO DEL USUARIO
            _buildUserInfo(usuario),
            const SizedBox(height: 32),

            // 🎉 MENSAJE DE ÉXITO
            if (_cambioExitoso) _buildSuccessMessage(),

            // 📝 FORMULARIO
            if (!_cambioExitoso) _buildPasswordForm(),

            // ❌ MENSAJE DE ERROR
            if (_error != null && !_cambioExitoso) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  // 👤 MÉTODO: Info del usuario
  Widget _buildUserInfo(Map<String, dynamic>? usuario) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Icon(
                Icons.person,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario?['nombre'] ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    usuario?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      usuario?['rol']?.toString().toUpperCase() ?? 'USUARIO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 MÉTODO: Construir formulario
  Widget _buildPasswordForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Para tu seguridad, necesitamos verificar tu contraseña actual.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // 🔐 CAMPO: Contraseña actual
              TextFormField(
                controller: _passwordActualController,
                obscureText: _obscureActual,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Contraseña Actual',
                  hintText: 'Ingresa tu contraseña actual',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureActual ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureActual = !_obscureActual;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña actual es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔐 CAMPO: Nueva contraseña
              TextFormField(
                controller: _passwordNuevoController,
                obscureText: _obscureNuevo,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNuevo ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNuevo = !_obscureNuevo;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La nueva contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  if (value == _passwordActualController.text) {
                    return 'La nueva contraseña debe ser diferente a la actual';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Revalidar confirmación si ya tiene texto
                  if (_confirmarPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 20),

              // 🔐 CAMPO: Confirmar nueva contraseña
              TextFormField(
                controller: _confirmarPasswordController,
                obscureText: _obscureConfirmar,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleCambiarPassword(),
                decoration: InputDecoration(
                  labelText: 'Confirmar Nueva Contraseña',
                  hintText: 'Repite la nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmar
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmar = !_obscureConfirmar;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Debes confirmar la nueva contraseña';
                  }
                  if (value != _passwordNuevoController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 🔘 BOTÓN: Cambiar contraseña
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCambiarPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CAMBIAR CONTRASEÑA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO: Mensaje de éxito
  Widget _buildSuccessMessage() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Contraseña Actualizada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu contraseña se ha cambiado correctamente. Ya puedes usar la nueva contraseña en tu próximo inicio de sesión.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ❌ MÉTODO: Mensaje de error
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔑 FUNCIÓN: Manejar cambio de contraseña
  Future<void> _handleCambiarPassword() async {
    setState(() {
      _error = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passwordActual = _passwordActualController.text.trim();
      final passwordNuevo = _passwordNuevoController.text.trim();

      final resultado = await UsuariosService.cambiarPassword(
        passwordActual: passwordActual,
        passwordNuevo: passwordNuevo,
      );

      if (resultado['exito'] == true) {
        // ✅ Cambio exitoso
        setState(() {
          _cambioExitoso = true;
        });
      } else {
        // ❌ Error
        setState(() {
          _error = resultado['error']?.toString() ?? 'Error desconocido';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
