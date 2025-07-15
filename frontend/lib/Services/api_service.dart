import 'dart:convert';                    // 🔄 Para convertir JSON a objetos Dart
import 'package:http/http.dart' as http; // 🌐 Para hacer peticiones HTTP a la API
import '../models/albaran.dart';          // 📋 Importar nuestro modelo Albaran

class ApiService {
  // 🏠 URL donde está corriendo nuestro backend Node.js
  static const String baseUrl = 'http://localhost:3000'; 

  // 📖 FUNCIÓN: Obtener todos los albaranes desde la API
  static Future<List<Albaran>> getAlbaranes() async {
    try {
      // 📡 Hacer petición GET a la API (equivale a ir al navegador a localhost:3000/albaranes)
      final response = await http.get(
        Uri.parse('$baseUrl/albaranes'),              // 🔗 URL completa: http://localhost:3000/albaranes
        headers: {'Content-Type': 'application/json'}, // 📨 Decir que esperamos JSON
      );

      // ✅ Si la respuesta es exitosa (código 200 = OK)
      if (response.statusCode == 200) {
        // 📋 Convertir el texto JSON en una lista de objetos Dart
        List<dynamic> jsonList = json.decode(response.body); // response.body = "[{id:1, cliente:'...'}]"
        
        // 🔄 Convertir cada elemento JSON en un objeto Albaran
        return jsonList.map((json) => Albaran.fromJson(json)).toList();
      } else {
        // ❌ Si el servidor responde con error (404, 500, etc.)
        throw Exception('Error al cargar albaranes');
      }
    } catch (e) {
      // 🚨 Si hay problemas de red, servidor apagado, etc.
      throw Exception('Error de conexión: $e');
    }
  }

  // ➕ FUNCIÓN: Crear un nuevo albarán
  static Future<bool> crearAlbaran({
    required String numeroAlbaran,    // 📝 Datos obligatorios
    required String cliente,
    String? direccionEntrega,         // 📝 Datos opcionales (? = puede ser null)
    String? observaciones,
  }) async {
    try {
      // 📤 Hacer petición POST (enviar datos) a la API
      final response = await http.post(
        Uri.parse('$baseUrl/albaranes'),              // 🔗 Misma URL pero POST en lugar de GET
        headers: {'Content-Type': 'application/json'}, // 📨 Decir que enviamos JSON
        body: json.encode({                           // 📦 Convertir datos Dart a JSON
          'numero_albaran': numeroAlbaran,            // 🏷️ Los mismos nombres que espera el backend
          'cliente': cliente,
          'direccion_entrega': direccionEntrega,
          'observaciones': observaciones,
        }),
      );

      // ✅ Si se creó correctamente, devolver true, sino false
      return response.statusCode == 200;
    } catch (e) {
      // ❌ Si hubo algún error, devolver false
      return false;
    }
  }
}