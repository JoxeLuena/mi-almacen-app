import 'dart:convert'; // 🔄 Para convertir JSON
import 'package:http/http.dart' as http; // 🌐 Para peticiones HTTP
import '../models/producto_disponible.dart'; // 📦 Modelo producto
import 'api_service.dart'; // 🌐 Servicio base

// 🔍 SERVICIO: Gestiona búsquedas y creación de productos
class BusquedaService {
  // 🔍 FUNCIÓN: Buscar productos por texto (referencia o descripción)
  static Future<List<ProductoDisponible>> buscarProductos(String query) async {
    // ✅ VALIDACIÓN: Mínimo 2 caracteres para buscar
    if (query.trim().length < 2) {
      return []; // 📋 Lista vacía si query muy corto
    }

    try {
      // 🌐 LLAMADA API: Buscar productos con autocompletado
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/productos/buscar?q=${Uri.encodeComponent(query)}',
        ), // 🔗 URL con query encoded
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si respuesta exitosa
        List<dynamic> jsonList = json.decode(
          response.body,
        ); // 📋 Decodificar JSON
        return jsonList // 🔄 Convertir cada JSON a ProductoDisponible
            .map((json) => ProductoDisponible.fromJson(json))
            .toList();
      } else {
        // ❌ Error del servidor
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // 🚨 Error de conexión
      throw Exception('Error de búsqueda: $e');
    }
  }

  // ➕ FUNCIÓN: Crear nuevo producto
  static Future<ProductoDisponible?> crearProducto({
    required String referencia, // 📝 Referencia obligatoria
    required String descripcion, // 📝 Descripción obligatoria
    required String uso, // 🎯 Uso obligatorio (produccion, mantenimiento, etc.)
    double? precio, // 💰 Precio opcional
    int? stockActual, // 📊 Stock inicial opcional
  }) async {
    try {
      // 🌐 LLAMADA API: Crear nuevo producto
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/productos'), // 🔗 URL crear producto
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          // 📦 Datos del producto
          'referencia': referencia.trim(), // 📝 Referencia limpia
          'descripcion': descripcion.trim(), // 📝 Descripción limpia
          'uso': uso, // 🎯 Categoría de uso
          'precio': precio, // 💰 Precio opcional
          'stock_actual': stockActual ?? 0, // 📊 Stock (por defecto 0)
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Si producto creado exitosamente
        final data = json.decode(response.body); // 📋 Datos del producto creado
        return ProductoDisponible.fromJson(data); // 🔄 Convertir a objeto
      } else {
        // ❌ Error al crear
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error creando producto');
      }
    } catch (e) {
      // 🚨 Error de conexión o datos
      throw Exception('Error creando producto: $e');
    }
  }

  // 📊 FUNCIÓN: Obtener resumen de productos de un albarán
  static Future<Map<String, dynamic>> obtenerResumenProductos(
    int albaranId,
  ) async {
    try {
      // 🌐 LLAMADA API: Obtener resumen estadístico
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId/productos/resumen',
        ), // 🔗 URL resumen
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si respuesta exitosa
        return json.decode(response.body); // 📊 Devolver datos de resumen
      } else {
        // ❌ Error del servidor
        throw Exception('Error obteniendo resumen');
      }
    } catch (e) {
      // 🚨 Error de conexión
      throw Exception('Error de resumen: $e');
    }
  }

  // 📝 FUNCIÓN: Validar referencia (formato, caracteres permitidos)
  static String? validarReferencia(String referencia) {
    final refLimpia = referencia
        .trim()
        .toUpperCase(); // 📝 Limpiar y convertir a mayúsculas

    // ✅ VALIDACIÓN 1: No puede estar vacía
    if (refLimpia.isEmpty) {
      return 'La referencia no puede estar vacía';
    }

    // ✅ VALIDACIÓN 2: Longitud mínima y máxima
    if (refLimpia.length < 3) {
      return 'La referencia debe tener al menos 3 caracteres';
    }
    if (refLimpia.length > 20) {
      return 'La referencia no puede tener más de 20 caracteres';
    }

    // ✅ VALIDACIÓN 3: Solo letras, números y algunos símbolos
    final regexValida = RegExp(
      r'^[A-Z0-9\-_]+$',
    ); // 📝 Patrón: letras, números, guión, guión bajo
    if (!regexValida.hasMatch(refLimpia)) {
      return 'La referencia solo puede contener letras, números, - y _';
    }

    return null; // ✅ Referencia válida
  }

  // 📝 FUNCIÓN: Validar descripción
  static String? validarDescripcion(String descripcion) {
    final descLimpia = descripcion.trim(); // 📝 Limpiar espacios

    // ✅ VALIDACIÓN 1: No puede estar vacía
    if (descLimpia.isEmpty) {
      return 'La descripción no puede estar vacía';
    }

    // ✅ VALIDACIÓN 2: Longitud mínima y máxima
    if (descLimpia.length < 5) {
      return 'La descripción debe tener al menos 5 caracteres';
    }
    if (descLimpia.length > 200) {
      return 'La descripción no puede tener más de 200 caracteres';
    }

    return null; // ✅ Descripción válida
  }

  // 🎯 FUNCIÓN: Obtener lista de usos disponibles
  static List<Map<String, String>> obtenerUsosDisponibles() {
    return [
      {'valor': 'produccion', 'etiqueta': 'Producción'}, // 🏭 Producción
      {
        'valor': 'mantenimiento',
        'etiqueta': 'Mantenimiento',
      }, // 🔧 Mantenimiento
      {'valor': 'logistica', 'etiqueta': 'Logística'}, // 📦 Logística
      {
        'valor': 'administracion',
        'etiqueta': 'Administración',
      }, // 📊 Administración
      {'valor': 'limpieza', 'etiqueta': 'Limpieza'}, // 🧹 Limpieza
      {
        'valor': 'epis',
        'etiqueta': 'EPIs',
      }, // 🦺 Equipos de Protección Individual
    ];
  }
}
