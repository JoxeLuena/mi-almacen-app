// 👤 MODELO: Usuario del sistema
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? ultimoAcceso;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    required this.fechaCreacion,
    this.ultimoAcceso,
  });

  // 🔄 FACTORY: Crear desde JSON (datos del backend)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'usuario',
      activo: json['activo'] == 1 || json['activo'] == true,
      fechaCreacion: _parseDateTime(json['created_at']), // ← Cambio aquí
      ultimoAcceso: _parseDateTime(json['ultimo_acceso']),
    );
  }

  // 📅 FUNCIÓN AUXILIAR: Parsear fechas del backend
  static DateTime _parseDateTime(dynamic fecha) {
    if (fecha == null) return DateTime.now();

    try {
      if (fecha is String) {
        return DateTime.parse(fecha);
      }
      return fecha as DateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  // 🔄 FUNCIÓN: Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'activo': activo,
      'created_at': fechaCreacion.toIso8601String(), // ← Cambio aquí
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
    };
  }

  // 📋 FUNCIÓN: Crear copia con cambios
  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    String? rol,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }

  @override
  String toString() {
    return 'Usuario{id: $id, nombre: $nombre, email: $email, rol: $rol, activo: $activo}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
