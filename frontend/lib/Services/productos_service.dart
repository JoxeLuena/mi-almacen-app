import 'dart:convert'; // 🔄 Para convertir JSON
import 'package:http/http.dart' as http; // 🌐 Para peticiones HTTP
import '../models/producto_disponible.dart'; // 📦 Modelo de producto disponible
import '../models/producto_seleccionado.dart'; // 📦 Modelo de producto seleccionado
import 'api_service.dart'; // 🌐 Servicio base con URL

// 🏢 SERVICIO: Gestiona todas las operaciones relacionadas con productos
// Similar a un MODULE en Visual Basic con funciones específicas
class ProductosService {
  // 📥 FUNCIÓN: Obtener todos los productos disponibles del almacén
  static Future<List<ProductoDisponible>> cargarProductosDisponibles() async {
    try {
      // 🌐 Hacer petición GET al backend para obtener productos
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/productos',
        ), // 🔗 URL del endpoint productos
        headers: {
          'Content-Type': 'application/json',
        }, // 📨 Especificar que esperamos JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si la respuesta es exitosa
        // 📋 Decodificar el JSON que devuelve el backend
        List<dynamic> jsonList = json.decode(response.body);

        // 🔄 Convertir cada elemento JSON a objeto ProductoDisponible
        return jsonList
            .map((json) => ProductoDisponible.fromJson(json))
            .toList();
      } else {
        // ❌ Si hay error del servidor
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // 📥 FUNCIÓN: Obtener productos de un albarán específico
  static Future<List<ProductoSeleccionado>> cargarProductosAlbaran(
    String albaranId,
  ) async {
    try {
      // 🌐 Hacer petición GET al backend para obtener productos del albarán
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId/productos',
        ), // 🔗 URL del endpoint productos de albarán
        headers: {
          'Content-Type': 'application/json',
        }, // 📨 Especificar que esperamos JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si la respuesta es exitosa
        // 📋 Decodificar el JSON que devuelve el backend
        List<dynamic> jsonList = json.decode(response.body);

        // 🔄 Convertir cada elemento JSON a objeto ProductoSeleccionado
        return jsonList
            .map((json) => ProductoSeleccionado.fromJson(json))
            .toList();
      } else {
        // ❌ Si hay error del servidor
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // ✏️ FUNCIÓN: Actualizar datos generales del albarán (NUEVA)
  static Future<bool> actualizarAlbaran({
    required int albaranId, // 🆔 ID del albarán
    required String cliente, // 👤 Cliente actualizado
    String? direccionEntrega, // 📍 Dirección actualizada
    String? observaciones, // 📝 Observaciones actualizadas
  }) async {
    try {
      // 🌐 Hacer petición PUT al backend para actualizar albarán
      final response = await http.put(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId',
        ), // 🔗 URL del albarán específico
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          'cliente': cliente, // 👤 Nuevo cliente
          'direccion_entrega': direccionEntrega, // 📍 Nueva dirección
          'observaciones': observaciones, // 📝 Nuevas observaciones
        }),
      );

      return response.statusCode == 200; // ✅ Devolver true si fue exitoso
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // ➕ FUNCIÓN: Añadir producto a un albarán existente (NUEVA)
  static Future<bool> anadirProductoAlbaran({
    required int albaranId, // 🆔 ID del albarán
    required int productoId, // 📦 ID del producto
    required int cantidad, // 🔢 Cantidad a añadir
    String? observaciones, // 📝 Observaciones opcionales
  }) async {
    try {
      // 🌐 Hacer petición POST al backend para añadir producto
      final response = await http.post(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId/productos',
        ), // 🔗 URL añadir producto
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          'producto_id': productoId, // 📦 ID del producto
          'cantidad': cantidad, // 🔢 Cantidad
          'observaciones': observaciones, // 📝 Observaciones
        }),
      );

      return response.statusCode == 200; // ✅ Devolver true si fue exitoso
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // ✏️ FUNCIÓN: Actualizar producto en un albarán (NUEVA)
  static Future<bool> actualizarProductoAlbaran({
    required int albaranId, // 🆔 ID del albarán
    required int productoId, // 📦 ID del producto
    required int cantidad, // 🔢 Nueva cantidad
    String? observaciones, // 📝 Nuevas observaciones
  }) async {
    try {
      // 🌐 Hacer petición PUT al backend para actualizar producto
      final response = await http.put(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId/productos/$productoId',
        ), // 🔗 URL producto específico
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          'cantidad': cantidad, // 🔢 Nueva cantidad
          'observaciones': observaciones, // 📝 Nuevas observaciones
        }),
      );

      return response.statusCode == 200; // ✅ Devolver true si fue exitoso
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // 🗑️ FUNCIÓN: Eliminar producto de un albarán (NUEVA)
  static Future<bool> eliminarProductoAlbaran({
    required int albaranId, // 🆔 ID del albarán
    required int productoId, // 📦 ID del producto
  }) async {
    try {
      // 🌐 Hacer petición DELETE al backend para eliminar producto
      final response = await http.delete(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/$albaranId/productos/$productoId',
        ), // 🔗 URL producto específico
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
      );

      return response.statusCode == 200; // ✅ Devolver true si fue exitoso
    } catch (e) {
      // 🚨 Si hay error de red o conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // 💾 FUNCIÓN: Crear albarán completo con productos
  static Future<Map<String, dynamic>> crearAlbaranCompleto({
    required String cliente, // 👤 Cliente obligatorio
    String? direccionEntrega, // 📍 Dirección opcional
    String? observaciones, // 📝 Observaciones opcionales
    required List<ProductoSeleccionado>
    productos, // 📦 Lista de productos seleccionados
  }) async {
    try {
      // 🌐 PASO 1: Crear el albarán base (sin productos)
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/albaranes'), // 🔗 URL crear albarán
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          // 📦 Datos del albarán
          'cliente': cliente, // 👤 Nombre del cliente
          'direccion_entrega': direccionEntrega, // 📍 Dirección de entrega
          'observaciones': observaciones, // 📝 Observaciones generales
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Si albarán creado exitosamente
        // 📋 Obtener datos del albarán creado (incluye ID y número generado)
        final albaranData = json.decode(response.body);
        final albaranId = albaranData['id']; // 🆔 ID del albarán nuevo

        // 🌐 PASO 2: Añadir cada producto al albarán
        for (final productoSel in productos) {
          // 🔄 Iterar cada producto seleccionado
          final productResponse = await http.post(
            Uri.parse(
              '${ApiService.baseUrl}/albaranes/$albaranId/productos',
            ), // 🔗 URL añadir producto
            headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
            body: json.encode(
              productoSel.toJson(),
            ), // 📦 Convertir producto a JSON
          );

          if (productResponse.statusCode != 200) {
            // ❌ Si error añadiendo producto
            throw Exception(
              'Error añadiendo producto ${productoSel.producto.referencia}',
            );
          }
        }

        // 🎉 ÉXITO: Devolver datos del albarán creado
        return {
          'exito': true, // ✅ Indicador de éxito
          'albaranId': albaranId, // 🆔 ID del albarán
          'numeroAlbaran':
              albaranData['numero_albaran'] ?? '', // 📝 Número generado
          'mensaje': 'Albarán creado correctamente',
        };
      } else {
        // ❌ Error al crear albarán base
        throw Exception(
          'Error del servidor al crear albarán: ${response.statusCode}',
        );
      }
    } catch (e) {
      // 🚨 Error durante el proceso
      // ❌ FALLO: Devolver información del error
      return {
        'exito': false, // ❌ Indicador de fallo
        'error': e.toString(), // 📝 Mensaje de error
        'mensaje': 'Error al crear el albarán',
      };
    }
  }

  // 🔍 FUNCIÓN: Validar datos antes de enviar
  static String? validarDatosAlbaran({
    required String cliente, // 👤 Cliente a validar
    required List<ProductoSeleccionado> productos, // 📦 Productos a validar
  }) {
    // ✅ VALIDACIÓN 1: Cliente obligatorio
    if (cliente.trim().isEmpty) {
      return 'El nombre del cliente es obligatorio'; // ⚠️ Error cliente vacío
    }

    // ✅ VALIDACIÓN 2: Al menos un producto
    if (productos.isEmpty) {
      return 'Debes añadir al menos un producto al albarán'; // ⚠️ Error sin productos
    }

    // ✅ VALIDACIÓN 3: Todos los productos deben ser válidos
    for (final producto in productos) {
      if (!producto.esValido) {
        return 'Producto ${producto.producto.referencia}: cantidad inválida'; // ⚠️ Error cantidad
      }
    }

    return null; // ✅ Todo válido
  }
}
