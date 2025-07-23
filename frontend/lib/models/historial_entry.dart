// 📊 MODELO: Entrada de historial de albarán
class HistorialEntry {
  final DateTime fecha;
  final String accion;
  final String estado;

  HistorialEntry({
    required this.fecha,
    required this.accion,
    required this.estado,
  });

  // 🔄 FACTORY: Crear desde JSON del backend
  factory HistorialEntry.fromJson(Map<String, dynamic> json) {
    return HistorialEntry(
      // 📅 Parsear fecha (puede venir como string)
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      // 📝 Acción realizada
      accion: json['accion']?.toString() ?? 'Acción desconocida',
      // 📊 Estado del albarán
      estado: json['estado']?.toString() ?? 'estado_desconocido',
    );
  }

  // 🔄 MÉTODO: Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'accion': accion,
      'estado': estado,
    };
  }

  // 📅 MÉTODO: Formatear fecha para mostrar
  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  // 🎨 MÉTODO: Obtener color según la acción
  String get colorPorAccion {
    switch (accion.toLowerCase()) {
      case 'creado':
        return 'azul';
      case 'enviado':
        return 'naranja';
      case 'entregado':
        return 'verde';
      default:
        return 'gris';
    }
  }

  // 🎯 MÉTODO: Obtener icono según la acción
  String get iconoPorAccion {
    switch (accion.toLowerCase()) {
      case 'creado':
        return 'crear';
      case 'enviado':
        return 'enviar';
      case 'entregado':
        return 'entregar';
      default:
        return 'info';
    }
  }
}
