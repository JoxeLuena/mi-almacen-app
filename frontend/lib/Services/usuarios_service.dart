import 'dart:convert';
import 'package:http/http.dart' as http;

// 👥 SERVICIO: Gestión de usuarios y autenticación
class UsuariosService {
  // 🌐 CONFIGURACIÓN: URL base del backend
  // static const String baseUrl = 'http://192.168.1.207:3000'; //desarrollo
  static const String baseUrl = 'https://850766ec91e4.ngrok-free.app';

  // 🔑 ALMACENAMIENTO: Token de autenticación (en producción usar secure storage)
  static String? _token;
  static Map<String, dynamic>? _usuarioActual;

  // 🔑 GETTER: Obtener token actual
  static String? get token => _token;

  // 👤 GETTER: Obtener usuario actual
  static Map<String, dynamic>? get usuarioActual => _usuarioActual;

  // 🔐 GETTER: Verificar si está autenticado
  static bool get estaAutenticado => _token != null;

  // 📝 FUNCIÓN: Headers con token para peticiones autenticadas
  static Map<String, String> _headersConToken() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // =================================
  // 🚀 CONFIGURACIÓN INICIAL
  // =================================

  // 🚀 FUNCIÓN: Crear primer administrador (sin autenticación)
  static Future<Map<String, dynamic>> crearPrimerAdmin({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Creando primer admin: $email'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/setup/primer-admin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );

      print('📡 Respuesta setup: ${response.statusCode}'); // Debug

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        print('✅ Primer admin creado exitosamente'); // Debug
        return {
          'exito': true,
          'usuario': data,
          'mensaje': data['mensaje'],
        };
      } else {
        print('❌ Error en setup: ${data['error']}'); // Debug
        return {
          'exito': false,
          'error': data['error'] ?? 'Error creando administrador',
        };
      }
    } catch (e) {
      print('❌ Error de conexión en setup: $e'); // Debug
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // =================================
  // 🔐 AUTENTICACIÓN
  // =================================

  // 🔐 FUNCIÓN: Login de usuario
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      print('🔐 Intentando login: $email'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Respuesta login: ${response.statusCode}'); // Debug

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // ✅ Login exitoso
        _token = data['token'];
        _usuarioActual = data['usuario'];

        print('✅ Login exitoso para: ${_usuarioActual?['nombre']}'); // Debug

        return {
          'exito': true,
          'usuario': data['usuario'],
          'mensaje': data['mensaje'],
        };
      } else {
        // ❌ Error en login
        print('❌ Error en login: ${data['error']}'); // Debug
        return {
          'exito': false,
          'error': data['error'] ?? 'Error en login',
        };
      }
    } catch (e) {
      print('❌ Error de conexión en login: $e'); // Debug
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // 🚪 FUNCIÓN: Logout
  static void logout() {
    print('🚪 Cerrando sesión'); // Debug
    _token = null;
    _usuarioActual = null;
  }

  // 🔍 FUNCIÓN: Verificar token
  static Future<bool> verificarToken() async {
    if (_token == null) {
      print('🔍 No hay token para verificar'); // Debug
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/verificar-token'),
        headers: _headersConToken(),
      );

      final esValido = response.statusCode == 200;
      print('🔍 Token ${esValido ? 'válido' : 'inválido'}'); // Debug

      return esValido;
    } catch (e) {
      print('❌ Error verificando token: $e'); // Debug
      return false;
    }
  }

  // =================================
  // 👥 GESTIÓN DE USUARIOS
  // =================================

  // 📋 FUNCIÓN: Obtener todos los usuarios
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      print('📋 Obteniendo usuarios...'); // Debug

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: _headersConToken(),
      );

      print('📡 Respuesta usuarios: ${response.statusCode}'); // Debug

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Usuarios obtenidos: ${data.length}'); // Debug
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('❌ Token inválido o expirado'); // Debug
        // Token inválido, hacer logout
        logout();
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      } else {
        print('❌ Error obteniendo usuarios: ${response.statusCode}'); // Debug
        throw Exception('Error obteniendo usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión obteniendo usuarios: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  // 👤 FUNCIÓN: Obtener usuario por ID
  static Future<Map<String, dynamic>> obtenerUsuario(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _headersConToken(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error obteniendo usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ➕ FUNCIÓN: Crear nuevo usuario
  static Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    String rol = 'usuario',
  }) async {
    try {
      print('➕ Creando usuario: $email'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: _headersConToken(),
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
        }),
      );

      print('📡 Respuesta crear usuario: ${response.statusCode}'); // Debug

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // ✅ Usuario creado exitosamente
        print('✅ Usuario creado: ${data['nombre']}'); // Debug
        return {
          'exito': true,
          'usuario': data,
          'mensaje': data['mensaje'],
        };
      } else {
        // ❌ Error en creación
        print('❌ Error creando usuario: ${data['error']}'); // Debug
        return {
          'exito': false,
          'error': data['error'] ?? 'Error creando usuario',
        };
      }
    } catch (e) {
      print('❌ Error de conexión creando usuario: $e'); // Debug
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ✏️ FUNCIÓN: Actualizar usuario
  static Future<Map<String, dynamic>> actualizarUsuario({
    required int id,
    required String nombre,
    required String email,
    String? rol,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'nombre': nombre,
        'email': email,
      };

      if (rol != null) body['rol'] = rol;
      if (password != null && password.isNotEmpty) body['password'] = password;

      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _headersConToken(),
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'],
        };
      } else {
        return {
          'exito': false,
          'error': data['error'] ?? 'Error actualizando usuario',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // 🔄 FUNCIÓN: Cambiar estado de usuario (activar/desactivar)
  static Future<Map<String, dynamic>> cambiarEstadoUsuario(
      int id, bool activo) async {
    try {
      print(
          '🔄 Cambiando estado usuario $id a ${activo ? 'activo' : 'inactivo'}'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id/estado'),
        headers: _headersConToken(),
        body: json.encode({'activo': activo}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ Estado cambiado exitosamente'); // Debug
        return {
          'exito': true,
          'mensaje': data['mensaje'],
        };
      } else {
        print('❌ Error cambiando estado: ${data['error']}'); // Debug
        return {
          'exito': false,
          'error': data['error'] ?? 'Error cambiando estado',
        };
      }
    } catch (e) {
      print('❌ Error de conexión cambiando estado: $e'); // Debug
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ❌ FUNCIÓN: Eliminar usuario (desactivar)
  static Future<Map<String, dynamic>> eliminarUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _headersConToken(),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'],
        };
      } else {
        return {
          'exito': false,
          'error': data['error'] ?? 'Error eliminando usuario',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // 🔍 FUNCIÓN: Buscar usuarios con filtros
  static Future<List<Map<String, dynamic>>> buscarUsuarios({
    String? busqueda,
    String? rol,
    String? estado,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (busqueda != null && busqueda.isNotEmpty) {
        queryParams['q'] = busqueda;
      }
      if (rol != null && rol != 'todos') {
        queryParams['rol'] = rol;
      }
      if (estado != null && estado != 'todos') {
        queryParams['activo'] = estado;
      }

      final uri = Uri.parse('$baseUrl/usuarios/buscar').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: _headersConToken(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error buscando usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 📊 FUNCIÓN: Obtener estadísticas de usuarios
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      print('📊 Obteniendo estadísticas...'); // Debug

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/estadisticas'),
        headers: _headersConToken(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Estadísticas obtenidas'); // Debug
        return data;
      } else {
        print(
            '❌ Error obteniendo estadísticas: ${response.statusCode}'); // Debug
        throw Exception(
            'Error obteniendo estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión obteniendo estadísticas: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔑 FUNCIÓN: Cambiar contraseña del usuario actual
  static Future<Map<String, dynamic>> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    try {
      print('🔑 Cambiando contraseña...'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/cambiar-password'),
        headers: _headersConToken(),
        body: json.encode({
          'passwordActual': passwordActual,
          'passwordNuevo': passwordNuevo,
        }),
      );

      print('📡 Respuesta cambio password: ${response.statusCode}'); // Debug

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ Contraseña cambiada exitosamente'); // Debug
        return {
          'exito': true,
          'mensaje': data['mensaje'],
        };
      } else {
        print('❌ Error cambiando contraseña: ${data['error']}'); // Debug
        return {
          'exito': false,
          'error': data['error'] ?? 'Error cambiando contraseña',
        };
      }
    } catch (e) {
      print('❌ Error de conexión cambiando contraseña: $e'); // Debug
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // 🎨 FUNCIÓN: Obtener color por rol
  static String obtenerColorRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return '#e74c3c'; // Rojo
      case 'supervisor':
        return '#f39c12'; // Naranja
      case 'usuario':
        return '#3498db'; // Azul
      default:
        return '#95a5a6'; // Gris
    }
  }

  // 📝 FUNCIÓN: Obtener nombre legible del rol
  static String obtenerNombreRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return 'Admin';
      case 'supervisor':
        return 'Supervisor';
      case 'usuario':
        return 'Usuario';
      default:
        return 'Desconocido';
    }
  }

  // 📅 FUNCIÓN: Formatear tiempo relativo
  static String formatearTiempoRelativo(String? fechaString) {
    if (fechaString == null) return 'Nunca';

    try {
      final fecha = DateTime.parse(fechaString);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inDays > 7) {
        return 'Hace ${diferencia.inDays} días';
      } else if (diferencia.inDays > 0) {
        return 'Hace ${diferencia.inDays} días';
      } else if (diferencia.inHours > 0) {
        return 'Hace ${diferencia.inHours}h';
      } else if (diferencia.inMinutes > 0) {
        return 'Hace ${diferencia.inMinutes}min';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return 'Desconocido';
    }
  }

  // ✅ FUNCIÓN: Validar email
  static bool validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 🔐 FUNCIÓN: Validar contraseña
  static String? validarPassword(String password) {
    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null; // Válida
  }

  // 📝 FUNCIÓN: Validar nombre
  static String? validarNombre(String nombre) {
    if (nombre.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (nombre.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null; // Válido
  }
}
