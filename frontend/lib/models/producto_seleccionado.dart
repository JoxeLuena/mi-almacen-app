import 'producto_disponible.dart'; // 📦 Importar el modelo de producto disponible

// 📦 MODELO: Representa un producto seleccionado para incluir en el albarán
// Combina un producto del almacén + cantidad + observaciones específicas
class ProductoSeleccionado {
  final ProductoDisponible producto; // 📦 Producto base del almacén
  int cantidad; // 🔢 Cantidad que se va a enviar
  String observaciones; // 📝 Notas específicas para este envío

  // 🏗️ CONSTRUCTOR: Crea un producto seleccionado
  ProductoSeleccionado({
    required this.producto, // 📦 Producto base obligatorio
    required this.cantidad, // 🔢 Cantidad obligatoria
    this.observaciones = '', // 📝 Observaciones opcionales (por defecto vacío)
  });

  // 🔧 MÉTODO: Crear objeto desde JSON (desde el servidor) - CORREGIDO
  factory ProductoSeleccionado.fromJson(Map<String, dynamic> json) {
    // 🔍 VERIFICACIÓN: ¿El JSON tiene un objeto 'producto' anidado?
    if (json.containsKey('producto') && json['producto'] != null) {
      // 📦 FORMATO 1: Producto anidado (para crear albarán)
      return ProductoSeleccionado(
        producto: ProductoDisponible.fromJson(
          json['producto'],
        ), // 📦 Crear producto desde JSON anidado
        cantidad: json['cantidad'] ?? 0, // 🔢 Cantidad
        observaciones: json['observaciones'] ?? '', // 📝 Observaciones
      );
    } else {
      // 📦 FORMATO 2: Datos del producto directamente (para mostrar albarán)
      return ProductoSeleccionado(
        producto: ProductoDisponible(
          id: json['producto_id'] ?? 0, // 🆔 ID del producto
          referencia: json['referencia'] ?? '', // 📝 Referencia
          descripcion: json['descripcion'] ?? '', // 📝 Descripción
          stockActual: json['stock_actual'] ?? 0, // 📊 Stock actual
        ),
        cantidad: json['cantidad'] ?? 0, // 🔢 Cantidad
        observaciones: json['observaciones'] ?? '', // 📝 Observaciones
      );
    }
  }

  // 📊 GETTER: Calcula el nombre completo para mostrar
  String get nombreCompleto {
    return '${producto.referencia} - ${producto.descripcion}';
  }

  // ✅ MÉTODO: Valida que los datos sean correctos
  bool get esValido {
    return cantidad > 0 &&
        cantidad <=
            producto
                .stockActual; // 🔍 Cantidad debe ser positiva y no superar stock
  }

  // 📋 MÉTODO: Convierte a Map para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'producto_id': producto.id, // 🆔 ID del producto
      'cantidad': cantidad, // 🔢 Cantidad seleccionada
      'observaciones':
          observaciones
              .isEmpty // 📝 Observaciones (null si está vacío)
          ? null
          : observaciones,
    };
  }

  // 📋 MÉTODO: Convierte el objeto a texto legible (para debug)
  @override
  String toString() {
    return 'ProductoSeleccionado{producto: ${producto.referencia}, cantidad: $cantidad, obs: $observaciones}';
  }
}
