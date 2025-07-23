import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/albaran.dart'; // 📋 Modelo de albarán
import '../services/api_service.dart'; // 🌐 Servicio API
import 'dart:convert';
import 'package:http/http.dart' as http;

// 📦 MODELO: Para representar un producto en el albarán
class ProductoAlbaran {
  final int lineaId; // 🆔 ID de la línea en albaran_lineas
  final int productoId; // 🆔 ID del producto
  final String referencia; // 📝 Referencia del producto (REF001)
  final String descripcion; // 📝 Descripción del producto
  final int cantidad; // 🔢 Cantidad en el albarán
  final String? observaciones; // 📝 Observaciones opcionales

  ProductoAlbaran({
    required this.lineaId,
    required this.productoId,
    required this.referencia,
    required this.descripcion,
    required this.cantidad,
    this.observaciones,
  });

  // 🔄 FUNCIÓN: Convertir JSON del backend a objeto Dart
  factory ProductoAlbaran.fromJson(Map<String, dynamic> json) {
    return ProductoAlbaran(
      lineaId: json['linea_id'] ?? 0, // 🆔 ID de la línea
      productoId: json['producto_id'] ?? 0, // 🆔 ID del producto
      referencia: json['referencia'] ?? '', // 📝 Referencia
      descripcion: json['descripcion'] ?? '', // 📝 Descripción
      cantidad: json['cantidad'] ?? 0, // 🔢 Cantidad
      observaciones: json['observaciones'], // 📝 Observaciones (puede ser null)
    );
  }
}

class ProductosAlbaranScreen extends StatefulWidget {
  // 📱 Pantalla de productos del albarán
  final Albaran albaran; // 📋 El albarán del que mostrar productos

  const ProductosAlbaranScreen({
    // 🏗️ Constructor
    super.key,
    required this.albaran, // 📋 Obligatorio pasar el albarán
  });

  @override
  State<ProductosAlbaranScreen> createState() => _ProductosAlbaranScreenState();
}

class _ProductosAlbaranScreenState extends State<ProductosAlbaranScreen> {
  List<ProductoAlbaran> productos = []; // 📦 Lista de productos del albarán
  bool isLoading = true; // ⏳ Indicador de carga
  String? error; // ❌ Mensaje de error

  @override
  void initState() {
    // 🚀 Se ejecuta al crear la pantalla
    super.initState();
    cargarProductos(); // 📥 Cargar productos del albarán
  }

  // 📥 FUNCIÓN: Cargar productos del albarán desde la API
  Future<void> cargarProductos() async {
    try {
      setState(() {
        // 🔄 Actualizar interfaz
        isLoading = true; // ⏳ Mostrar carga
        error = null; // 🧹 Limpiar errores
      });

      // 🌐 LLAMADA API: Obtener productos del albarán
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/${widget.albaran.id}/productos',
        ), // 🔗 URL específica del albarán
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si la respuesta es exitosa
        List<dynamic> jsonList = json.decode(
          response.body,
        ); // 📋 Decodificar JSON
        setState(() {
          // 🔄 Actualizar interfaz
          productos = jsonList
              .map((json) => ProductoAlbaran.fromJson(json))
              .toList(); // 📦 Convertir a objetos
          isLoading = false; // ✅ Ya no está cargando
        });
      } else {
        // ❌ Si hay error del servidor
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      // 🚨 Si hay excepción
      setState(() {
        // 🔄 Actualizar interfaz
        isLoading = false; // ✅ Ya no está cargando
        error = 'Error: $e'; // ❌ Mostrar error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Construir la interfaz
    return Scaffold(
      // 📱 Estructura básica
      appBar: AppBar(
        // 📊 Barra superior
        title: Text(
          'Productos - ${widget.albaran.numeroAlbaran}',
        ), // 🏷️ Título con número de albarán
        backgroundColor: Colors.blue, // 🎨 Color azul
        foregroundColor: Colors.white, // ⚪ Texto blanco
        actions: [
          // 🔘 Botones en la barra superior
          IconButton(
            // ➕ Botón para añadir producto
            icon: const Icon(Icons.add), // ➕ Icono más
            onPressed: () {
              // 👆 Qué hacer al pulsar
              // TODO: Navegar a pantalla añadir producto
              ScaffoldMessenger.of(context).showSnackBar(
                // 🔔 Mensaje temporal
                const SnackBar(content: Text('Añadir producto - Próximamente')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(), // 📄 Contenido principal
    );
  }

  // 📄 FUNCIÓN: Construir el contenido principal
  Widget _buildBody() {
    if (isLoading) {
      // ⏳ Si está cargando
      return const Center(
        // 🎯 Centrar
        child: CircularProgressIndicator(), // ⭕ Ruedita de carga
      );
    }

    if (error != null) {
      // ❌ Si hay error
      return Center(
        // 🎯 Centrar
        child: Column(
          // 📋 Columna vertical
          mainAxisAlignment:
              MainAxisAlignment.center, // 🎯 Centrar verticalmente
          children: [
            Text(error!), // ❌ Mostrar error
            const SizedBox(height: 16), // 📏 Espacio
            ElevatedButton(
              // 🔄 Botón reintentar
              onPressed: cargarProductos, // 👆 Recargar productos
              child: const Text('Reintentar'), // 🏷️ Texto del botón
            ),
          ],
        ),
      );
    }

    if (productos.isEmpty) {
      // 📦 Si no hay productos
      return Center(
        // 🎯 Centrar
        child: Column(
          // 📋 Columna vertical
          mainAxisAlignment:
              MainAxisAlignment.center, // 🎯 Centrar verticalmente
          children: [
            const Icon(
              // 📦 Icono de caja vacía
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16), // 📏 Espacio
            const Text(
              // 📝 Mensaje de albarán vacío
              'Este albarán no tiene productos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16), // 📏 Espacio
            ElevatedButton.icon(
              // ➕ Botón para añadir primer producto
              onPressed: () {
                // 👆 Qué hacer al pulsar
                // TODO: Navegar a añadir producto
                ScaffoldMessenger.of(context).showSnackBar(
                  // 🔔 Mensaje temporal
                  const SnackBar(
                    content: Text('Añadir primer producto - Próximamente'),
                  ),
                );
              },
              icon: const Icon(Icons.add), // ➕ Icono más
              label: const Text('Añadir Producto'), // 🏷️ Texto del botón
            ),
          ],
        ),
      );
    }

    // ✅ Si hay productos, mostrar la lista
    return ListView.builder(
      // 📋 Lista desplazable
      padding: const EdgeInsets.all(8), // 📏 Margen alrededor
      itemCount: productos.length, // 📊 Cuántos productos mostrar
      itemBuilder: (context, index) {
        // 🏗️ Cómo construir cada elemento
        final producto = productos[index]; // 📦 Producto actual
        return Card(
          // 🃏 Tarjeta para cada producto
          margin: const EdgeInsets.only(bottom: 8), // 📏 Margen inferior
          child: ListTile(
            // 📋 Elemento de lista
            leading: CircleAvatar(
              // 🔵 Círculo a la izquierda
              backgroundColor: Colors.blue, // 🎨 Fondo azul
              child: Text(
                // 📝 Cantidad en el círculo
                '${producto.cantidad}', // 🔢 Mostrar cantidad
                style: const TextStyle(color: Colors.white), // ⚪ Texto blanco
              ),
            ),
            title: Text(
              // 🏷️ Título principal
              '${producto.referencia} - ${producto.descripcion}', // 📝 Referencia y descripción
              style: const TextStyle(fontWeight: FontWeight.bold), // 🔤 Negrita
            ),
            subtitle:
                producto.observaciones !=
                    null // 📝 Subtítulo condicional
                ? Text(
                    'Obs: ${producto.observaciones}',
                  ) // 📝 Si hay observaciones
                : null, // ❌ Si no hay observaciones
            trailing: Row(
              // ➡️ Botones a la derecha
              mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
              children: [
                IconButton(
                  // ✏️ Botón editar
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.orange,
                  ), // ✏️ Icono naranja
                  onPressed: () {
                    // 👆 Qué hacer al pulsar
                    // TODO: Editar cantidad/observaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      // 🔔 Mensaje temporal
                      const SnackBar(
                        content: Text('Editar producto - Próximamente'),
                      ),
                    );
                  },
                ),
                IconButton(
                  // 🗑️ Botón eliminar
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ), // 🗑️ Icono rojo
                  onPressed: () {
                    // 👆 Qué hacer al pulsar
                    _confirmarEliminar(
                      producto,
                    ); // 🚨 Confirmar antes de eliminar
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🚨 FUNCIÓN: Confirmar eliminación de producto
  void _confirmarEliminar(ProductoAlbaran producto) {
    showDialog(
      // 📱 Mostrar diálogo de confirmación
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 🚨 Diálogo de alerta
          title: const Text('Confirmar eliminación'), // 🏷️ Título del diálogo
          content: Text(
            // 📝 Contenido del diálogo
            '¿Estás seguro de que quieres eliminar "${producto.referencia} - ${producto.descripcion}" del albarán?',
          ),
          actions: [
            // 🔘 Botones del diálogo
            TextButton(
              // ❌ Botón cancelar
              onPressed: () => Navigator.of(context).pop(), // 🔙 Cerrar diálogo
              child: const Text('Cancelar'), // 🏷️ Texto del botón
            ),
            TextButton(
              // 🗑️ Botón eliminar
              onPressed: () {
                // 👆 Qué hacer al confirmar
                Navigator.of(context).pop(); // 🔙 Cerrar diálogo
                _eliminarProducto(producto); // 🗑️ Eliminar producto
              },
              style: TextButton.styleFrom(
                // 🎨 Estilo del botón
                foregroundColor: Colors.red, // 🔴 Texto rojo
              ),
              child: const Text('Eliminar'), // 🏷️ Texto del botón
            ),
          ],
        );
      },
    );
  }

  // 🗑️ FUNCIÓN: Eliminar producto del albarán
  Future<void> _eliminarProducto(ProductoAlbaran producto) async {
    try {
      // 🌐 LLAMADA API: Eliminar producto del albarán
      final response = await http.delete(
        Uri.parse(
          '${ApiService.baseUrl}/albaranes/${widget.albaran.id}/productos/${producto.lineaId}',
        ), // 🔗 URL específica
        headers: {'Content-Type': 'application/json'}, // 📨 Headers JSON
      );

      if (response.statusCode == 200) {
        // ✅ Si se eliminó correctamente
        ScaffoldMessenger.of(context).showSnackBar(
          // 🔔 Mensaje de éxito
          const SnackBar(
            content: Text('✅ Producto eliminado correctamente'),
            backgroundColor: Colors.green, // 🟢 Fondo verde
          ),
        );
        cargarProductos(); // 📥 Recargar lista para actualizar
      } else {
        // ❌ Si hubo error
        throw Exception('Error al eliminar producto');
      }
    } catch (e) {
      // 🚨 Si hay excepción
      ScaffoldMessenger.of(context).showSnackBar(
        // 🔔 Mensaje de error
        SnackBar(
          content: Text('❌ Error: $e'), // 📢 Mostrar error
          backgroundColor: Colors.red, // 🔴 Fondo rojo
        ),
      );
    }
  }
}
