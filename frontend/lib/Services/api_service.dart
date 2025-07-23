import 'dart:convert'; // 🔄 Para convertir JSON a objetos Dart
import 'package:http/http.dart'
    as http; // 🌐 Para hacer peticiones HTTP a la API
import '../models/albaran.dart'; // 📋 Importar nuestro modelo Albaran
import '../models/historial_entry.dart'; // 📊 Importar modelo de historial
import '../config/app_config.dart';

class ApiService {
  // 🏠 URL donde está corriendo nuestro backend Node.js
  static const String baseUrl = 'http://localhost:3000';
  //static const String baseUrl = AppConfig.baseUrl;
  // static const String baseUrl = 'http://192.168.1.207:3000';
  // 📖 FUNCIÓN: Obtener todos los albaranes desde la API
  static Future<List<Albaran>> getAlbaranes() async {
    try {
      // 📡 Hacer petición GET a la API (equivale a ir al navegador a localhost:3000/albaranes)
      final response = await http.get(
        Uri.parse(
          '$baseUrl/albaranes',
        ), // 🔗 URL completa: http://localhost:3000/albaranes
        headers: {
          'Content-Type': 'application/json',
        }, // 📨 Decir que esperamos JSON
      );

      // ✅ Si la respuesta es exitosa (código 200 = OK)
      if (response.statusCode == 200) {
        // 📋 Convertir el texto JSON en una lista de objetos Dart
        List<dynamic> jsonList = json.decode(
          response.body,
        ); // response.body = "[{id:1, cliente:'...'}]"

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

  // 📊 FUNCIÓN: Obtener historial de un albarán
  static Future<List<HistorialEntry>> getHistorialAlbaran(int albaranId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/albaranes/$albaranId/historial'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => HistorialEntry.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar historial');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ➕ FUNCIÓN: Crear nuevo albarán (SIN número manual, se genera automáticamente)
  static Future<bool> crearAlbaran({
    required String cliente, // 👤 Solo cliente es obligatorio ahora
    String? direccionEntrega, // 📍 Opcional
    String? observaciones, // 📝 Opcional
    // numeroAlbaran: ELIMINADO, se genera automáticamente en el backend
  }) async {
    try {
      // 📤 Hacer petición POST a la API
      final response = await http.post(
        Uri.parse('$baseUrl/albaranes'), // 🔗 URL del backend
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
        body: json.encode({
          // 📦 Datos a enviar
          // 'numero_albaran': NO enviamos esto, se genera automáticamente
          'cliente': cliente, // 👤 Cliente
          'direccion_entrega': direccionEntrega, // 📍 Dirección opcional
          'observaciones': observaciones, // 📝 Observaciones opcional
        }),
      );

      return response.statusCode == 200; // ✅ Devolver true si fue exitoso
    } catch (e) {
      return false; // ❌ Devolver false si hubo error
    }
  }
}
