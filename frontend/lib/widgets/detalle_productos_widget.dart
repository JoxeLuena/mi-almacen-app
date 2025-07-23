import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/producto_disponible.dart'; // 📦 Modelo producto disponible
import '../models/producto_seleccionado.dart'; // 📦 Modelo producto seleccionado
import '../services/productos_service.dart'; // 🏢 Servicio productos
import 'autocompletado_producto_widget.dart'; // 🔍 Widget autocompletado

// 📦 WIDGET: Gestión completa de productos del albarán
class DetalleProductosWidget extends StatelessWidget {
  final int albaranId; // 🆔 ID del albarán
  final List<ProductoSeleccionado>
  productosAlbaran; // 📋 Lista de productos del albarán
  final bool isLoadingProductos; // ⏳ Indicador de carga
  final String? errorProductos; // ❌ Error al cargar
  final VoidCallback onRecargarProductos; // 🔄 Callback para recargar
  final Function(String) onMostrarError; // ⚠️ Callback para mostrar errores

  const DetalleProductosWidget({
    super.key,
    required this.albaranId, // 🆔 ID del albarán obligatorio
    required this.productosAlbaran, // 📋 Lista de productos obligatoria
    required this.isLoadingProductos, // ⏳ Estado de carga obligatorio
    required this.errorProductos, // ❌ Error opcional
    required this.onRecargarProductos, // 🔄 Callback recarga obligatorio
    required this.onMostrarError, // ⚠️ Callback error obligatorio
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // 🃏 Tarjeta con sombra
      elevation: 4, // 🌫️ Nivel de sombra
      child: Padding(
        // 📏 Margen interno
        padding: const EdgeInsets.all(16.0), // 📏 16 píxeles en todos lados
        child: Column(
          // 📋 Columna con productos
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
          children: [
            // 🏷️ ENCABEZADO: Título con botón añadir
            _buildEncabezado(context), // 🏗️ Construir encabezado
            const SizedBox(height: 16), // 📏 Espacio vertical
            // 📦 CONTENIDO: Lista de productos según estado
            _buildContenidoProductos(context), // 🏗️ Construir contenido
          ],
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir encabezado con título y botón
  Widget _buildEncabezado(BuildContext context) {
    return Row(
      // ➡️ Fila horizontal
      children: [
        const Icon(
          Icons.inventory,
          color: Colors.green,
          size: 24,
        ), // 📦 Icono verde
        const SizedBox(width: 8), // 📏 Espacio horizontal
        const Text(
          // 🏷️ Título
          'Productos del Albarán',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ), // 🎨 Estilo verde
        ),
        const Spacer(), // 🔄 Espacio flexible
        // 📊 CONTADOR: Cantidad de productos
        Container(
          // 📦 Contenedor del contador
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ), // 📏 Padding
          decoration: BoxDecoration(
            // 🎨 Decoración
            color: Colors.green.shade100, // 🟢 Fondo verde claro
            borderRadius: BorderRadius.circular(12), // 🔄 Bordes redondeados
          ),
          child: Text(
            // 📊 Texto del contador
            '${productosAlbaran.length} items', // 📝 Cantidad de productos
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ), // 🎨 Estilo
          ),
        ),
        const SizedBox(width: 12), // 📏 Espacio horizontal
        // ➕ BOTÓN: Añadir producto
        ElevatedButton.icon(
          // 🔘 Botón con icono
          onPressed: () =>
              _mostrarDialogoAnadirProducto(context), // 👆 Acción añadir
          icon: const Icon(Icons.add, size: 18), // ➕ Icono añadir pequeño
          label: const Text('Añadir'), // 🏷️ Texto del botón
          style: ElevatedButton.styleFrom(
            // 🎨 Estilo del botón
            backgroundColor: Colors.green, // 🟢 Fondo verde
            foregroundColor: Colors.white, // ⚪ Texto blanco
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // 📏 Padding pequeño
          ),
        ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir contenido según el estado
  Widget _buildContenidoProductos(BuildContext context) {
    if (isLoadingProductos) {
      // ⏳ Si está cargando
      return const Center(
        // 🎯 Centrar contenido
        child: Padding(
          // 📏 Padding
          padding: EdgeInsets.all(32.0), // 📏 32 píxeles
          child: CircularProgressIndicator(), // ⭕ Indicador de carga
        ),
      );
    }

    if (errorProductos != null) {
      // ❌ Si hay error
      return _buildErrorWidget(); // 🏗️ Construir widget de error
    }

    if (productosAlbaran.isEmpty) {
      // 📋 Si no hay productos
      return _buildWidgetVacio(); // 🏗️ Construir widget vacío
    }

    // 📋 LISTA: Mostrar productos
    return _buildListaProductos(context); // 🏗️ Construir lista de productos
  }

  // 🏗️ MÉTODO: Construir widget de error
  Widget _buildErrorWidget() {
    return Container(
      // 📦 Contenedor de error
      padding: const EdgeInsets.all(16), // 📏 Padding
      decoration: BoxDecoration(
        // 🎨 Decoración
        color: Colors.red.shade50, // 🔴 Fondo rojo claro
        borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
        border: Border.all(color: Colors.red.shade200), // 🔴 Borde rojo
      ),
      child: Column(
        // 📋 Columna con error
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 32,
          ), // ❌ Icono de error
          const SizedBox(height: 8), // 📏 Espacio
          Text(
            // 📝 Mensaje de error
            'Error al cargar productos',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ), // 🎨 Estilo
          ),
          const SizedBox(height: 4), // 📏 Espacio pequeño
          Text(
            // 📝 Detalle del error
            errorProductos!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ), // 🎨 Estilo pequeño
          ),
          const SizedBox(height: 8), // 📏 Espacio
          ElevatedButton(
            // 🔘 Botón reintentar
            onPressed: onRecargarProductos, // 👆 Acción reintentar
            child: const Text('Reintentar'), // 🏷️ Texto del botón
          ),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir widget vacío
  Widget _buildWidgetVacio() {
    return Container(
      // 📦 Contenedor vacío
      padding: const EdgeInsets.all(24), // 📏 Padding grande
      decoration: BoxDecoration(
        // 🎨 Decoración
        color: Colors.grey.shade50, // ⚫ Fondo gris claro
        borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
        border: Border.all(color: Colors.grey.shade300), // ⚫ Borde gris
      ),
      child: Column(
        // 📋 Columna con mensaje vacío
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey.shade400,
            size: 48,
          ), // 📦 Icono gris
          const SizedBox(height: 12), // 📏 Espacio
          Text(
            // 📝 Mensaje vacío
            'Sin productos en este albarán',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ), // 🎨 Estilo
          ),
          const SizedBox(height: 4), // 📏 Espacio pequeño
          Text(
            // 💡 Sugerencia
            'Usa el botón "Añadir" para agregar productos',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ), // 🎨 Estilo pequeño
          ),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir lista de productos
  Widget _buildListaProductos(BuildContext context) {
    return Column(
      // 📋 Columna con productos
      children: productosAlbaran.asMap().entries.map((entry) {
        // 🗂️ Mapear cada producto con índice
        final index = entry.key; // 🔢 Índice del producto
        final producto = entry.value; // 📦 Producto actual

        return Container(
          // 📦 Contenedor de cada producto
          margin: const EdgeInsets.only(bottom: 8), // 📏 Margen inferior
          padding: const EdgeInsets.all(12), // 📏 Padding interno
          decoration: BoxDecoration(
            // 🎨 Decoración
            color: Colors.white, // ⚪ Fondo blanco
            borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
            border: Border.all(color: Colors.grey.shade300), // ⚫ Borde gris
          ),
          child: Row(
            // ➡️ Fila horizontal
            children: [
              // 📦 ICONO: Producto
              Container(
                // 📦 Contenedor del icono
                padding: const EdgeInsets.all(8), // 📏 Padding
                decoration: BoxDecoration(
                  // 🎨 Decoración
                  color: Colors.blue.shade100, // 🔵 Fondo azul claro
                  borderRadius: BorderRadius.circular(6), // 🔄 Bordes pequeños
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.blue.shade600,
                  size: 20,
                ), // 📦 Icono azul
              ),
              const SizedBox(width: 12), // 📏 Espacio horizontal
              // 📝 INFORMACIÓN: Datos del producto
              Expanded(
                // 📏 Expandir para ocupar espacio disponible
                child: Column(
                  // 📋 Columna con datos
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
                  children: [
                    // 📝 REFERENCIA: Del producto
                    Text(
                      producto.producto.referencia, // 📝 Mostrar referencia
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ), // 🎨 Estilo negrita
                    ),
                    const SizedBox(height: 2), // 📏 Espacio pequeño
                    // 📝 DESCRIPCIÓN: Del producto
                    Text(
                      producto.producto.descripcion, // 📝 Mostrar descripción
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ), // 🎨 Estilo gris
                    ),
                    // 📝 OBSERVACIONES: Si las hay
                    if (producto.observaciones.isNotEmpty) ...[
                      const SizedBox(height: 4), // 📏 Espacio
                      Text(
                        'Obs: ${producto.observaciones}', // 📝 Mostrar observaciones
                        style: TextStyle(
                          color: Colors.orange.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ), // 🎨 Estilo cursiva
                      ),
                    ],
                  ],
                ),
              ),
              // 🔢 CANTIDAD: En círculo con botones
              Column(
                // 📋 Columna con cantidad y botones
                mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
                children: [
                  Container(
                    // 📦 Contenedor de la cantidad
                    padding: const EdgeInsets.all(8), // 📏 Padding
                    decoration: BoxDecoration(
                      // 🎨 Decoración
                      color: Colors.green.shade100, // 🟢 Fondo verde claro
                      shape: BoxShape.circle, // ⭕ Forma circular
                    ),
                    child: Text(
                      // 🔢 Texto de la cantidad
                      '${producto.cantidad}', // 📝 Mostrar cantidad
                      style: TextStyle(
                        // 🎨 Estilo
                        color: Colors.green.shade700, // 🟢 Texto verde oscuro
                        fontWeight: FontWeight.bold, // 🔤 Negrita
                        fontSize: 14, // 📏 Tamaño
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // 📏 Espacio pequeño
                  // 🔘 BOTONES: Acciones del producto
                  Row(
                    // ➡️ Fila con botones
                    mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
                    children: [
                      IconButton(
                        // ✏️ Botón editar
                        icon: Icon(
                          Icons.edit,
                          color: Colors.orange.shade600,
                          size: 18,
                        ), // ✏️ Icono editar
                        onPressed: () =>
                            _editarProducto(context, index), // 👆 Acción editar
                        tooltip: 'Editar cantidad', // 💡 Tooltip
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ), // 📏 Tamaño mínimo
                      ),
                      IconButton(
                        // 🗑️ Botón eliminar
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade600,
                          size: 18,
                        ), // 🗑️ Icono eliminar
                        onPressed: () => _eliminarProducto(
                          context,
                          index,
                        ), // 👆 Acción eliminar
                        tooltip: 'Eliminar producto', // 💡 Tooltip
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ), // 📏 Tamaño mínimo
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(), // 📋 Convertir a lista
    );
  }

  // ➕ FUNCIÓN: Mostrar diálogo para añadir producto
  void _mostrarDialogoAnadirProducto(BuildContext context) {
    ProductoDisponible? productoSeleccionado; // 📦 Producto elegido
    final cantidadController = TextEditingController(
      text: '1',
    ); // 🔢 Cantidad inicial
    final observacionesController =
        TextEditingController(); // 📝 Observaciones vacías

    showDialog(
      // 📱 Mostrar diálogo
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // 🔄 Builder con estado
          builder: (context, setDialogState) {
            return AlertDialog(
              // 📱 Diálogo
              title: const Text('Añadir Producto al Albarán'), // 🏷️ Título
              content: SizedBox(
                // 📦 Contenedor
                width: 400, // 📏 Ancho fijo
                child: Column(
                  // 📋 Columna con campos
                  mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
                  children: [
                    // 🔍 AUTOCOMPLETADO: Para buscar productos
                    AutocompletadoProductoWidget(
                      onProductoSeleccionado: (ProductoDisponible producto) {
                        // 🔗 Callback selección
                        setDialogState(() {
                          productoSeleccionado =
                              producto; // 📦 Guardar producto
                        });
                      },
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 🔢 CAMPO: Cantidad
                    TextFormField(
                      controller: cantidadController, // 🔗 Controlador
                      decoration: const InputDecoration(
                        // 🎨 Decoración
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // ⌨️ Teclado numérico
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 📝 CAMPO: Observaciones
                    TextFormField(
                      controller: observacionesController, // 🔗 Controlador
                      decoration: const InputDecoration(
                        // 🎨 Decoración
                        labelText: 'Observaciones',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2, // 📏 2 líneas máximo
                    ),
                    // 📊 INFO: Producto seleccionado
                    if (productoSeleccionado !=
                        null) // 🔍 Solo si hay selección
                      Container(
                        // 📦 Contenedor info
                        margin: const EdgeInsets.only(top: 16), // 📏 Margen
                        padding: const EdgeInsets.all(12), // 📏 Padding
                        decoration: BoxDecoration(
                          // 🎨 Decoración
                          color: Colors.green.shade50, // 🟢 Fondo verde claro
                          borderRadius: BorderRadius.circular(8), // 🔄 Bordes
                        ),
                        child: Text(
                          // 📝 Texto info
                          'Seleccionado: ${productoSeleccionado!.referencia}\nStock: ${productoSeleccionado!.stockActual}',
                          style: const TextStyle(
                            color: Colors.green,
                          ), // 🟢 Texto verde
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                // 🔘 Botones
                TextButton(
                  // ❌ Cancelar
                  onPressed: () {
                    cantidadController.dispose(); // 🧹 Limpiar
                    observacionesController.dispose(); // 🧹 Limpiar
                    Navigator.of(context).pop(); // 🔙 Cerrar
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  // ✅ Añadir
                  onPressed: () => _procesarAnadirProducto(
                    // 👆 Procesar
                    context,
                    productoSeleccionado,
                    cantidadController,
                    observacionesController,
                  ),
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ➕ FUNCIÓN: Procesar añadir producto
  Future<void> _procesarAnadirProducto(
    BuildContext context,
    ProductoDisponible? producto,
    TextEditingController cantidadController,
    TextEditingController observacionesController,
  ) async {
    // ✅ VALIDACIONES
    if (producto == null) {
      // 🔍 Sin producto
      onMostrarError('Selecciona un producto'); // ⚠️ Error
      return;
    }

    final cantidad = int.tryParse(
      cantidadController.text,
    ); // 🔢 Convertir cantidad
    if (cantidad == null || cantidad <= 0) {
      // 🔍 Cantidad inválida
      onMostrarError('La cantidad debe ser un número mayor a 0'); // ⚠️ Error
      return;
    }

    if (cantidad > producto.stockActual) {
      // 🔍 Supera stock
      onMostrarError(
        'La cantidad no puede superar el stock disponible (${producto.stockActual})',
      ); // ⚠️ Error
      return;
    }

    try {
      // 🌐 LLAMADA AL SERVICIO: Añadir producto
      final resultado = await ProductosService.anadirProductoAlbaran(
        albaranId: albaranId, // 🆔 ID del albarán
        productoId: producto.id, // 🆔 ID del producto
        cantidad: cantidad, // 🔢 Cantidad
        observaciones: observacionesController.text.trim().isEmpty
            ? null
            : observacionesController.text.trim(), // 📝 Observaciones
      );

      if (resultado) {
        // ✅ Éxito
        // 🧹 Limpiar y cerrar
        cantidadController.dispose();
        observacionesController.dispose();
        Navigator.of(context).pop();

        // 🔔 Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${producto.referencia} añadido al albarán'),
            backgroundColor: Colors.green,
          ),
        );

        onRecargarProductos(); // 🔄 Recargar lista
      } else {
        // ❌ Error
        onMostrarError('Error al añadir el producto');
      }
    } catch (e) {
      // 🚨 Excepción
      onMostrarError('Error de conexión: $e');
    }
  }

  // ✏️ FUNCIÓN: Editar producto
  void _editarProducto(BuildContext context, int index) {
    final producto = productosAlbaran[index]; // 📦 Producto a editar
    final cantidadController = TextEditingController(
      text: producto.cantidad.toString(),
    ); // 🔢 Cantidad actual
    final observacionesController = TextEditingController(
      text: producto.observaciones,
    ); // 📝 Observaciones actuales

    showDialog(
      // 📱 Mostrar diálogo
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 📱 Diálogo
          title: Text(
            'Editar ${producto.producto.referencia}',
          ), // 🏷️ Título con referencia
          content: Column(
            // 📋 Columna con campos
            mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
            children: [
              // 📝 INFO: Producto (solo lectura)
              Container(
                // 📦 Contenedor info
                padding: const EdgeInsets.all(12), // 📏 Padding
                decoration: BoxDecoration(
                  // 🎨 Decoración
                  color: Colors.blue.shade50, // 🔵 Fondo azul claro
                  borderRadius: BorderRadius.circular(8), // 🔄 Bordes
                ),
                child: Text(
                  // 📝 Descripción
                  producto.producto.descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // 🔤 Negrita
                ),
              ),
              const SizedBox(height: 16), // 📏 Espacio
              // 🔢 CAMPO: Nueva cantidad
              TextFormField(
                controller: cantidadController, // 🔗 Controlador
                decoration: const InputDecoration(
                  // 🎨 Decoración
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // ⌨️ Teclado numérico
              ),
              const SizedBox(height: 16), // 📏 Espacio
              // 📝 CAMPO: Nuevas observaciones
              TextFormField(
                controller: observacionesController, // 🔗 Controlador
                decoration: const InputDecoration(
                  // 🎨 Decoración
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2, // 📏 2 líneas máximo
              ),
            ],
          ),
          actions: [
            // 🔘 Botones
            TextButton(
              // ❌ Cancelar
              onPressed: () {
                cantidadController.dispose(); // 🧹 Limpiar
                observacionesController.dispose(); // 🧹 Limpiar
                Navigator.of(context).pop(); // 🔙 Cerrar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              // ✅ Guardar
              onPressed: () => _guardarEdicionProducto(
                // 👆 Guardar cambios
                context,
                index,
                cantidadController,
                observacionesController,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ✅ FUNCIÓN: Guardar edición de producto
  Future<void> _guardarEdicionProducto(
    BuildContext context,
    int index,
    TextEditingController cantidadController,
    TextEditingController observacionesController,
  ) async {
    // ✅ VALIDACIONES
    final nuevaCantidad = int.tryParse(
      cantidadController.text,
    ); // 🔢 Convertir cantidad
    if (nuevaCantidad == null || nuevaCantidad <= 0) {
      // 🔍 Cantidad inválida
      onMostrarError('La cantidad debe ser un número mayor a 0'); // ⚠️ Error
      return;
    }

    final producto = productosAlbaran[index]; // 📦 Producto actual
    if (nuevaCantidad > producto.producto.stockActual) {
      // 🔍 Supera stock
      onMostrarError(
        'La cantidad no puede superar el stock disponible (${producto.producto.stockActual})',
      ); // ⚠️ Error
      return;
    }

    try {
      // 🌐 LLAMADA AL SERVICIO: Actualizar producto
      final resultado = await ProductosService.actualizarProductoAlbaran(
        albaranId: albaranId, // 🆔 ID del albarán
        productoId: producto.producto.id, // 🆔 ID del producto
        cantidad: nuevaCantidad, // 🔢 Nueva cantidad
        observaciones: observacionesController.text.trim().isEmpty
            ? null
            : observacionesController.text.trim(), // 📝 Nuevas observaciones
      );

      if (resultado) {
        // ✅ Éxito
        // 🧹 Limpiar y cerrar
        cantidadController.dispose();
        observacionesController.dispose();
        Navigator.of(context).pop();

        // 🔔 Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        onRecargarProductos(); // 🔄 Recargar lista
      } else {
        // ❌ Error
        onMostrarError('Error al actualizar el producto');
      }
    } catch (e) {
      // 🚨 Excepción
      onMostrarError('Error de conexión: $e');
    }
  }

  // 🗑️ FUNCIÓN: Eliminar producto
  void _eliminarProducto(BuildContext context, int index) {
    final producto = productosAlbaran[index]; // 📦 Producto a eliminar

    // 🚨 Diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 📱 Diálogo
          title: const Text('Confirmar eliminación'), // 🏷️ Título
          content: Text(
            '¿Estás seguro de que quieres eliminar "${producto.nombreCompleto}" del albarán?',
          ), // 📝 Mensaje
          actions: [
            // 🔘 Botones
            TextButton(
              // ❌ Cancelar
              onPressed: () =>
                  Navigator.of(context).pop(), // 🔙 Cerrar sin eliminar
              child: const Text('Cancelar'),
            ),
            TextButton(
              // 🗑️ Eliminar
              onPressed: () => _confirmarEliminarProducto(
                context,
                index,
              ), // 👆 Confirmar eliminación
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ), // 🎨 Estilo rojo
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // 🗑️ FUNCIÓN: Confirmar eliminación
  Future<void> _confirmarEliminarProducto(
    BuildContext context,
    int index,
  ) async {
    final producto = productosAlbaran[index]; // 📦 Producto a eliminar

    try {
      // 🌐 LLAMADA AL SERVICIO: Eliminar producto
      final resultado = await ProductosService.eliminarProductoAlbaran(
        albaranId: albaranId, // 🆔 ID del albarán
        productoId: producto.producto.id, // 🆔 ID del producto
      );

      if (resultado) {
        // ✅ Éxito
        Navigator.of(context).pop(); // 🔙 Cerrar diálogo confirmación

        // 🔔 Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto eliminado del albarán'),
            backgroundColor: Colors.orange,
          ),
        );

        onRecargarProductos(); // 🔄 Recargar lista
      } else {
        // ❌ Error
        onMostrarError('Error al eliminar el producto');
      }
    } catch (e) {
      // 🚨 Excepción
      onMostrarError('Error de conexión: $e');
    }
  }
}
