import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // 🌐 Para obtener baseUrl

// 📝 MODELO: Log de actividad
class LogActividad {
  final int id;
  final int? usuarioId;
  final String accion;
  final String descripcion;
  final Map<String, dynamic>? detalles;
  final String? ipAddress;
  final DateTime createdAt;
  final String? usuarioNombre;
  final String? usuarioEmail;

  LogActividad({
    required this.id,
    this.usuarioId,
    required this.accion,
    required this.descripcion,
    this.detalles,
    this.ipAddress,
    required this.createdAt,
    this.usuarioNombre,
    this.usuarioEmail,
  });

  // 🔄 FUNCIÓN: Convertir JSON del backend a objeto Dart
  factory LogActividad.fromJson(Map<String, dynamic> json) {
    return LogActividad(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'],
      accion: json['accion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      detalles: json['detalles'], // Ya viene parseado del backend
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      usuarioNombre: json['usuario_nombre'],
      usuarioEmail: json['usuario_email'],
    );
  }

  // 📊 GETTER: Obtener icono según el tipo de acción
  String get iconoAccion {
    switch (accion.toUpperCase()) {
      case 'LOGIN':
        return '🔐';
      case 'LOGOUT':
        return '🚪';
      case 'CREAR_ALBARAN':
        return '📋';
      case 'CREAR_PRODUCTO':
        return '📦';
      case 'CREAR_USUARIO':
        return '👤';
      case 'CAMBIO_PASSWORD':
        return '🔑';
      case 'ACTUALIZAR_ALBARAN':
        return '✏️';
      case 'IMPRIMIR_ALBARAN':
        return '🖨️';
      case 'ELIMINAR':
        return '🗑️';
      case 'SISTEMA_INICIO':
        return '🚀';
      case 'ERROR':
        return '❌';
      case 'SETUP':
        return '⚙️';
      default:
        return '📝';
    }
  }

  // 🎨 GETTER: Color según el tipo de acción
  String get colorAccion {
    switch (accion.toUpperCase()) {
      case 'LOGIN':
      case 'LOGOUT':
        return '#4CAF50'; // Verde
      case 'CREAR_ALBARAN':
      case 'CREAR_PRODUCTO':
      case 'CREAR_USUARIO':
        return '#2196F3'; // Azul
      case 'ACTUALIZAR_ALBARAN':
      case 'CAMBIO_PASSWORD':
        return '#FF9800'; // Naranja
      case 'ELIMINAR':
      case 'ERROR':
        return '#F44336'; // Rojo
      case 'IMPRIMIR_ALBARAN':
        return '#9C27B0'; // Morado
      case 'SISTEMA_INICIO':
      case 'SETUP':
        return '#607D8B'; // Gris azulado
      default:
        return '#757575'; // Gris
    }
  }

  // 📅 GETTER: Formato de fecha legible
  String get fechaFormateada {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

// 📝 MODELO: Estadísticas de logs
class EstadisticasLogs {
  final int totalActividades;
  final int usuariosActivos;
  final int totalLogins;
  final int usuariosCreados;
  final int albaranesCreados;
  final int actividades24h;
  final int actividades7d;

  EstadisticasLogs({
    required this.totalActividades,
    required this.usuariosActivos,
    required this.totalLogins,
    required this.usuariosCreados,
    required this.albaranesCreados,
    required this.actividades24h,
    required this.actividades7d,
  });

  factory EstadisticasLogs.fromJson(Map<String, dynamic> json) {
    return EstadisticasLogs(
      totalActividades: json['total_actividades'] ?? 0,
      usuariosActivos: json['usuarios_activos'] ?? 0,
      totalLogins: json['total_logins'] ?? 0,
      usuariosCreados: json['usuarios_creados'] ?? 0,
      albaranesCreados: json['albaranes_creados'] ?? 0,
      actividades24h: json['actividades_24h'] ?? 0,
      actividades7d: json['actividades_7d'] ?? 0,
    );
  }
}

// 📝 SERVICIO: Gestión de logs de actividad
class LogsService {
  // 📝 FUNCIÓN: Headers básicos para peticiones (SIN autenticación por ahora)
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // 📋 FUNCIÓN: Obtener logs de actividad con filtros
  static Future<List<LogActividad>> obtenerLogs({
    int limit = 50,
    int offset = 0,
    int? usuarioId,
    String? accion,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      print('📝 Obteniendo logs de actividad...'); // Debug

      // 🔧 Construir parámetros de consulta
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (usuarioId != null) {
        queryParams['usuario_id'] = usuarioId.toString();
      }

      if (accion != null && accion.isNotEmpty) {
        queryParams['accion'] = accion;
      }

      if (fechaDesde != null) {
        queryParams['fecha_desde'] = fechaDesde.toIso8601String();
      }

      if (fechaHasta != null) {
        queryParams['fecha_hasta'] = fechaHasta.toIso8601String();
      }

      // 🌐 Hacer petición al backend
      final uri = Uri.parse('${ApiService.baseUrl}/logs/actividad')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final logs = data.map((log) => LogActividad.fromJson(log)).toList();

        print('✅ ${logs.length} logs obtenidos'); // Debug
        return logs;
      } else {
        print('❌ Error obteniendo logs: ${response.statusCode}'); // Debug
        throw Exception('Error obteniendo logs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión obteniendo logs: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  // 📊 FUNCIÓN: Obtener estadísticas de actividad
  static Future<EstadisticasLogs> obtenerEstadisticas() async {
    try {
      print('📊 Obteniendo estadísticas de logs...'); // Debug

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/logs/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Estadísticas de logs obtenidas'); // Debug
        return EstadisticasLogs.fromJson(data);
      } else {
        print(
            '❌ Error obteniendo estadísticas de logs: ${response.statusCode}'); // Debug
        throw Exception(
            'Error obteniendo estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión obteniendo estadísticas de logs: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔍 FUNCIÓN: Buscar en logs
  static Future<List<LogActividad>> buscarLogs(String query) async {
    try {
      if (query.trim().length < 2) {
        return [];
      }

      print('🔍 Buscando logs: $query'); // Debug

      final uri = Uri.parse('${ApiService.baseUrl}/logs/buscar').replace(
        queryParameters: {'q': query, 'limit': '20'},
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final logs = data.map((log) => LogActividad.fromJson(log)).toList();

        print('✅ ${logs.length} logs encontrados en búsqueda'); // Debug
        return logs;
      } else {
        throw Exception('Error buscando logs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión buscando logs: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  // 📝 FUNCIÓN: Obtener acciones disponibles para filtros
  static List<String> get accionesDisponibles => [
        'LOGIN',
        'LOGOUT',
        'CREAR_ALBARAN',
        'ACTUALIZAR_ALBARAN',
        'IMPRIMIR_ALBARAN',
        'CREAR_PRODUCTO',
        'CREAR_USUARIO',
        'CAMBIO_PASSWORD',
        'ELIMINAR',
        'SISTEMA_INICIO',
        'SETUP',
        'ERROR',
      ];
}
