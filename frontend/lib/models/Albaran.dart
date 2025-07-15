class Albaran {
  final int id;
  final String numeroAlbaran;
  final String cliente;
  final String? direccionEntrega;
  final String estado;
  final DateTime fechaCreacion;
  final String? observaciones;

  Albaran({
    required this.id,
    required this.numeroAlbaran,
    required this.cliente,
    this.direccionEntrega,
    required this.estado,
    required this.fechaCreacion,
    this.observaciones,
  });

  // 🔧 MÉTODO MEJORADO: Conversión JSON a objeto Dart (más robusto)
  factory Albaran.fromJson(Map<String, dynamic> json) {
    return Albaran(
      id: json['id'] ?? 0,                                    // 🆔 Si no existe, usar 0
      numeroAlbaran: json['numero_albaran'] ?? '',            // 📝 Si no existe, usar texto vacío
      cliente: json['cliente'] ?? '',                         // 👤 Si no existe, usar texto vacío
      direccionEntrega: json['direccion_entrega'],            // 📍 Puede ser null, está permitido
      estado: json['estado'] ?? 'pendiente',                  // 📊 Si no existe, usar "pendiente"
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? DateTime.now().toIso8601String()), // 📅 Parsear fecha ISO, si falla usar fecha actual
      observaciones: json['observaciones'],                   // 📝 Puede ser null, está permitido
    );
  }
}