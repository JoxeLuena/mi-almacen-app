// 📦 MODELO: Representa un producto disponible en el almacén
// Similar a una CLASS en Visual Basic
class ProductoDisponible {
  final int id; // 🆔 Identificador único del producto
  final String referencia; // 📝 Código de referencia (REF001, REF002, etc.)
  final String descripcion; // 📝 Descripción detallada del producto
  final int stockActual; // 📊 Cantidad disponible en almacén

  // 🏗️ CONSTRUCTOR: Crea una instancia del producto
  ProductoDisponible({
    required this.id, // 🆔 ID obligatorio
    required this.referencia, // 📝 Referencia obligatoria
    required this.descripcion, // 📝 Descripción obligatoria
    required this.stockActual, // 📊 Stock obligatorio
  });

  // 🔄 FACTORY: Convierte JSON del backend a objeto ProductoDisponible
  // Se usa cuando recibimos datos del servidor Node.js
  factory ProductoDisponible.fromJson(Map<String, dynamic> json) {
    return ProductoDisponible(
      id: json['id'] ?? 0, // 🆔 Si viene null, usar 0
      referencia:
          json['referencia'] ?? '', // 📝 Si viene null, usar texto vacío
      descripcion:
          json['descripcion'] ?? '', // 📝 Si viene null, usar texto vacío
      stockActual: json['stock_actual'] ?? 0, // 📊 Si viene null, usar 0
    );
  }

  // 📋 MÉTODO: Convierte el objeto a texto legible (para debug)
  @override
  String toString() {
    return 'ProductoDisponible{id: $id, referencia: $referencia, descripcion: $descripcion, stock: $stockActual}';
  }
}
