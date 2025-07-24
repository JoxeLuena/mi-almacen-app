import 'dart:convert';
import 'package:http/http.dart' as http;

// 📊 SERVICIO: Gestión de estados de albaranes
class EstadosService {
  // static const String baseUrl = 'http://192.168.1.207:3000'; // desarrollo
  static const String baseUrl = 'https://850766ec91e4.ngrok-free.app'; // NGOK

  // 📤 FUNCIÓN: Marcar albarán como enviado
  static Future<bool> marcarComoEnviado(int albaranId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/albaranes/$albaranId/enviar'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marcando como enviado: $e');
    }
  }

  // 📦 FUNCIÓN: Marcar albarán como entregado
  static Future<bool> marcarComoEntregado(
    int albaranId, {
    String? receptorConfirma,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/albaranes/$albaranId/entregar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'receptor_confirma': receptorConfirma,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marcando como entregado: $e');
    }
  }
}
