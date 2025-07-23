import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/producto_disponible.dart'; // 📦 Modelo producto disponible
import '../models/producto_seleccionado.dart'; // 📦 Modelo producto seleccionado
import '../services/productos_service.dart'; // 🏢 Servicio productos (como MODULE en VB)
import '../widgets/datos_generales_widget.dart'; // 📋 Widget datos generales
import '../widgets/productos_widget.dart'; // 📦 Widget productos
import '../widgets/autocompletado_producto_widget.dart'; // 🔍 Widget autocompletado

// 📱 PANTALLA: Crear albarán completo (datos + productos)
// Pantalla principal que coordina todos los componentes modulares
class CrearAlbaranScreen extends StatefulWidget {
  const CrearAlbaranScreen({super.key});

  @override
  State<CrearAlbaranScreen> createState() => _CrearAlbaranScreenState();
}

class _CrearAlbaranScreenState extends State<CrearAlbaranScreen> {
  // 📝 CONTROLADORES: Para capturar texto de campos principales
  final TextEditingController _clienteController =
      TextEditingController(); // 👤 Cliente
  final TextEditingController _direccionController =
      TextEditingController(); // 📍 Dirección
  final TextEditingController _observacionesController =
      TextEditingController(); // 📝 Observaciones

  // 📦 ESTADO: Productos y estado de la aplicación
  List<ProductoDisponible> productosDisponibles =
      []; // 📋 Lista productos almacén
  List<ProductoSeleccionado> productosSeleccionados =
      []; // 📋 Lista productos elegidos
  bool isLoadingProductos = false; // ⏳ Cargando productos del almacén
  bool _isLoading = false; // ⏳ Guardando albarán completo
  String? errorProductos; // ❌ Error al cargar productos

  @override
  void initState() {
    // 🚀 Ejecutar al crear la pantalla
    super.initState();
    _cargarProductosDisponibles(); // 📥 Cargar productos del almacén
  }

  @override
  void dispose() {
    // 🗑️ Limpiar memoria al cerrar pantalla
    _clienteController.dispose(); // 🧹 Liberar controlador cliente
    _direccionController.dispose(); // 🧹 Liberar controlador dirección
    _observacionesController.dispose(); // 🧹 Liberar controlador observaciones
    super.dispose();
  }

  // 📥 FUNCIÓN: Cargar productos disponibles del almacén
  Future<void> _cargarProductosDisponibles() async {
    setState(() {
      // 🔄 Actualizar interfaz
      isLoadingProductos = true; // ⏳ Mostrar estado de carga
      errorProductos = null; // 🧹 Limpiar errores anteriores
    });

    try {
      // 🌐 LLAMADA AL SERVICIO: Obtener productos del almacén
      final productos = await ProductosService.cargarProductosDisponibles();

      setState(() {
        // 🔄 Actualizar interfaz con datos
        productosDisponibles = productos; // 📦 Guardar productos obtenidos
        isLoadingProductos = false; // ✅ Terminar estado de carga
      });
    } catch (e) {
      // 🚨 Manejar errores
      setState(() {
        // 🔄 Actualizar interfaz con error
        isLoadingProductos = false; // ✅ Terminar estado de carga
        errorProductos = e.toString(); // ❌ Guardar mensaje de error
      });
      _mostrarError(
        'Error al cargar productos: $e',
      ); // 🔔 Mostrar error al usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Construir la interfaz principal
    return Scaffold(
      // 📱 Estructura básica de pantalla
      appBar: AppBar(
        // 📊 Barra superior
        title: const Text(
          'Crear Albarán Completo',
        ), // 🏷️ Título de la pantalla
        backgroundColor: Colors.blue, // 🎨 Color azul corporativo
        foregroundColor: Colors.white, // ⚪ Texto blanco
      ),
      body:
          _isLoading // 🔄 Mostrar contenido según estado
          ? _buildPantallaGuardando() // ⏳ Si guardando: pantalla de carga
          : _buildFormularioPrincipal(), // 📋 Si no guardando: formulario principal
    );
  }

  // 🏗️ MÉTODO: Construir pantalla de guardando
  Widget _buildPantallaGuardando() {
    return const Center(
      // 🎯 Centrar contenido
      child: Column(
        // 📋 Columna vertical
        mainAxisAlignment: MainAxisAlignment.center, // 🎯 Centrar verticalmente
        children: [
          CircularProgressIndicator(strokeWidth: 3), // ⭕ Ruedita de carga
          SizedBox(height: 20), // 📏 Espacio vertical
          Text(
            'Guardando albarán...', // 📝 Mensaje de estado
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ), // 🔤 Estilo
          ),
          SizedBox(height: 8), // 📏 Espacio pequeño
          Text(
            'Por favor, espera mientras se crean los registros', // 💡 Mensaje adicional
            style: TextStyle(fontSize: 12, color: Colors.grey), // 🎨 Estilo
            textAlign: TextAlign.center, // 🎯 Centrar texto
          ),
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir formulario principal
  Widget _buildFormularioPrincipal() {
    return SingleChildScrollView(
      // 📜 Scroll vertical si contenido largo
      padding: const EdgeInsets.all(16), // 📏 Margen alrededor del contenido
      child: Column(
        // 📋 Columna vertical con componentes
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // ↔️ Estirar componentes al ancho
        children: [
          // 📋 SECCIÓN 1: Datos generales (widget modular)
          DatosGeneralesWidget(
            clienteController:
                _clienteController, // 🔗 Pasar controlador cliente
            direccionController:
                _direccionController, // 🔗 Pasar controlador dirección
            observacionesController:
                _observacionesController, // 🔗 Pasar controlador observaciones
          ),

          const SizedBox(height: 24), // 📏 Espacio entre secciones
          // 📦 SECCIÓN 2: Productos del albarán (widget modular)
          ProductosWidget(
            productosDisponibles:
                productosDisponibles, // 📋 Pasar productos almacén
            productosSeleccionados:
                productosSeleccionados, // 📋 Pasar productos elegidos
            isLoading: isLoadingProductos, // ⏳ Pasar estado carga
            onAnadirProducto:
                _mostrarDialogoAnadirProducto, // 🔗 Callback añadir
            onEditarProducto: _editarProducto, // 🔗 Callback editar
            onEliminarProducto: _eliminarProducto, // 🔗 Callback eliminar
          ),

          const SizedBox(height: 24), // 📏 Espacio antes de botones
          // 🔘 SECCIÓN 3: Botones de acción
          _buildBotonesAccion(), // 🏗️ Botones guardar/cancelar
        ],
      ),
    );
  }

  // 🏗️ MÉTODO: Construir botones de acción (guardar/cancelar)
  Widget _buildBotonesAccion() {
    return Row(
      // ➡️ Fila horizontal con botones
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // 🎯 Distribuir uniformemente
      children: [
        // ❌ BOTÓN: Cancelar
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () => Navigator.pop(context), // 👆 Acción cancelar
          icon: const Icon(Icons.cancel), // ❌ Icono cancelar
          label: const Text('Cancelar'), // 🏷️ Texto del botón
          style: ElevatedButton.styleFrom(
            // 🎨 Estilo del botón
            backgroundColor: Colors.grey, // ⚫ Fondo gris
            foregroundColor: Colors.white, // ⚪ Texto blanco
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ), // 📏 Padding
          ),
        ),

        // ✅ BOTÓN: Guardar albarán completo
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : _guardarAlbaranCompleto, // 👆 Función guardar
          icon:
              _isLoading // 🔄 Icono dinámico según estado
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ), // ⏳ Ruedita
                )
              : const Icon(Icons.save), // 💾 Icono guardar
          label: Text(
            _isLoading ? 'Guardando...' : 'Guardar Albarán',
          ), // 🏷️ Texto dinámico
          style: ElevatedButton.styleFrom(
            // 🎨 Estilo del botón
            backgroundColor: Colors.green, // 🟢 Fondo verde
            foregroundColor: Colors.white, // ⚪ Texto blanco
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ), // 📏 Padding
          ),
        ),
      ],
    );
  }

  // ➕ FUNCIÓN: Mostrar diálogo para añadir producto
  void _mostrarDialogoAnadirProducto() {
    ProductoDisponible? productoSeleccionado; // 📦 Producto elegido
    final cantidadController = TextEditingController(text: '1'); // 🔢 Cantidad
    final observacionesController = TextEditingController(); // 📝 Observaciones

    showDialog(
      // 📱 Mostrar diálogo
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // 🔄 Builder con estado
          builder: (context, setDialogState) {
            return AlertDialog(
              // 📱 Diálogo simple
              title: const Text('Añadir Producto'), // 🏷️ Título
              content: SizedBox(
                // 📦 Contenedor con tamaño fijo
                width: 400, // 📏 Ancho fijo
                child: Column(
                  // 📋 Columna con campos
                  mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
                  children: [
                    // 🔍 WIDGET AUTOCOMPLETADO
                    AutocompletadoProductoWidget(
                      onProductoSeleccionado: (ProductoDisponible producto) {
                        // 👆 Callback selección
                        setDialogState(() {
                          productoSeleccionado =
                              producto; // 📦 Guardar producto
                        });
                      },
                    ),

                    const SizedBox(height: 16), // 📏 Espacio
                    // 🔢 CAMPO: Cantidad
                    TextFormField(
                      controller: cantidadController, // 🔗 Controlador cantidad
                      decoration: const InputDecoration(
                        labelText: 'Cantidad', // 🏷️ Etiqueta
                        prefixIcon: Icon(Icons.numbers), // 🔢 Icono
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      keyboardType: TextInputType.number, // ⌨️ Teclado numérico
                    ),

                    const SizedBox(height: 16), // 📏 Espacio
                    // 📝 CAMPO: Observaciones
                    TextFormField(
                      controller:
                          observacionesController, // 🔗 Controlador observaciones
                      decoration: const InputDecoration(
                        labelText: 'Observaciones', // 🏷️ Etiqueta
                        prefixIcon: Icon(Icons.note), // 📝 Icono
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      maxLines: 2, // 📏 Permitir 2 líneas
                    ),

                    // 📊 INFO: Producto seleccionado (si hay)
                    if (productoSeleccionado !=
                        null) // 🔍 Solo mostrar si hay selección
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
                          'Seleccionado: ${productoSeleccionado!.referencia}\nStock: ${productoSeleccionado!.stockActual}', // 📊 Info producto
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
                  onPressed: () {
                    // 🧹 Limpiar controladores antes de cerrar
                    cantidadController.dispose();
                    observacionesController.dispose();
                    Navigator.of(context).pop(); // 🔙 Cerrar
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => _procesarAgregarProducto(
                    productoSeleccionado,
                    cantidadController,
                    observacionesController,
                  ), // 👆 Procesar agregar
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ➕ FUNCIÓN: Procesar agregar producto (simplificada)
  void _procesarAgregarProducto(
    ProductoDisponible? producto,
    TextEditingController cantidadController,
    TextEditingController observacionesController,
  ) {
    // ✅ VALIDACIÓN: Producto seleccionado
    if (producto == null) {
      _mostrarError('Selecciona un producto'); // ⚠️ Error sin producto
      return;
    }

    // ✅ VALIDACIÓN: Cantidad válida
    final cantidad = int.tryParse(cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      _mostrarError(
        'La cantidad debe ser un número mayor a 0',
      ); // ⚠️ Error cantidad
      return;
    }

    // ✅ VALIDACIÓN: No superar stock disponible
    if (cantidad > producto.stockActual) {
      _mostrarError(
        'La cantidad no puede superar el stock disponible (${producto.stockActual})',
      ); // ⚠️ Error stock
      return;
    }

    // ➕ AÑADIR: Producto a la lista de seleccionados
    setState(() {
      productosSeleccionados.add(
        ProductoSeleccionado(
          producto: producto, // 📦 Producto base
          cantidad: cantidad, // 🔢 Cantidad especificada
          observaciones: observacionesController.text
              .trim(), // 📝 Observaciones limpias
        ),
      );
    });

    // 🧹 LIMPIAR: Liberar recursos y cerrar diálogo
    cantidadController.dispose();
    observacionesController.dispose();
    Navigator.of(context).pop(); // 🔙 Cerrar diálogo

    // 🔔 CONFIRMACIÓN: Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ ${producto.referencia} añadido al albarán',
        ), // 📢 Mensaje
        backgroundColor: Colors.green, // 🟢 Fondo verde
      ),
    );
  }

  // ✏️ FUNCIÓN: Editar producto ya seleccionado
  void _editarProducto(int index) {
    final producto =
        productosSeleccionados[index]; // 📦 Obtener producto a editar
    final cantidadController = TextEditingController(
      text: producto.cantidad.toString(),
    ); // 🔢 Controlador
    final observacionesController = TextEditingController(
      text: producto.observaciones,
    ); // 📝 Controlador

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar ${producto.producto.referencia}',
          ), // 🏷️ Título con referencia
          content: Column(
            mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
            children: [
              // 📝 INFORMACIÓN: Producto (solo lectura)
              Container(
                padding: const EdgeInsets.all(12), // 📏 Padding interno
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // 🔵 Fondo azul claro
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // 🔄 Bordes redondeados
                ),
                child: Text(
                  producto.producto.descripcion, // 📝 Descripción producto
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // 🔤 Negrita
                ),
              ),

              const SizedBox(height: 16), // 📏 Espacio
              // 🔢 CAMPO: Nueva cantidad
              TextFormField(
                controller: cantidadController, // 🔗 Conectar controlador
                decoration: const InputDecoration(
                  labelText: 'Cantidad', // 🏷️ Etiqueta
                  prefixIcon: Icon(Icons.numbers), // 🔢 Icono números
                  border: OutlineInputBorder(), // 🔲 Borde
                ),
                keyboardType: TextInputType.number, // ⌨️ Teclado numérico
              ),

              const SizedBox(height: 16), // 📏 Espacio
              // 📝 CAMPO: Nuevas observaciones
              TextFormField(
                controller: observacionesController, // 🔗 Conectar controlador
                decoration: const InputDecoration(
                  labelText: 'Observaciones', // 🏷️ Etiqueta
                  prefixIcon: Icon(Icons.note), // 📝 Icono nota
                  border: OutlineInputBorder(), // 🔲 Borde
                ),
                maxLines: 2, // 📏 Permitir 2 líneas
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 🧹 Limpiar controladores antes de cerrar
                cantidadController.dispose();
                observacionesController.dispose();
                Navigator.of(context).pop(); // 🔙 Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _guardarEdicionProducto(
                index,
                cantidadController,
                observacionesController,
              ), // 👆 Función guardar cambios
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ✅ FUNCIÓN: Guardar edición de producto
  void _guardarEdicionProducto(
    int index,
    TextEditingController cantidadController,
    TextEditingController observacionesController,
  ) {
    // ✅ VALIDACIÓN: Cantidad válida
    final nuevaCantidad = int.tryParse(cantidadController.text);
    if (nuevaCantidad == null || nuevaCantidad <= 0) {
      _mostrarError(
        'La cantidad debe ser un número mayor a 0',
      ); // ⚠️ Error cantidad
      return;
    }

    // ✅ VALIDACIÓN: No superar stock
    final producto =
        productosSeleccionados[index]; // 📦 Obtener producto actual
    if (nuevaCantidad > producto.producto.stockActual) {
      _mostrarError(
        'La cantidad no puede superar el stock disponible (${producto.producto.stockActual})',
      ); // ⚠️ Error stock
      return;
    }

    // 💾 GUARDAR: Cambios en el producto
    setState(() {
      productosSeleccionados[index].cantidad =
          nuevaCantidad; // 🔢 Actualizar cantidad
      productosSeleccionados[index].observaciones = observacionesController.text
          .trim(); // 📝 Actualizar observaciones
    });

    // 🧹 LIMPIAR: Liberar recursos y cerrar diálogo
    cantidadController.dispose();
    observacionesController.dispose();
    Navigator.of(context).pop(); // 🔙 Cerrar diálogo

    // 🔔 CONFIRMACIÓN: Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ Producto actualizado correctamente',
        ), // 📢 Mensaje éxito
        backgroundColor: Colors.green, // 🟢 Fondo verde
      ),
    );
  }

  // 🗑️ FUNCIÓN: Eliminar producto de la lista
  void _eliminarProducto(int index) {
    final producto =
        productosSeleccionados[index]; // 📦 Obtener producto a eliminar

    // 🚨 CONFIRMACIÓN: Diálogo antes de eliminar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'), // 🏷️ Título
          content: Text(
            '¿Estás seguro de que quieres eliminar "${producto.nombreCompleto}" del albarán?',
          ), // 📝 Mensaje
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // 🔙 Cerrar sin eliminar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // 👆 Eliminar producto
                setState(() {
                  productosSeleccionados.removeAt(
                    index,
                  ); // 🗑️ Eliminar de lista
                });
                Navigator.of(context).pop(); // 🔙 Cerrar diálogo

                // 🔔 CONFIRMACIÓN: Mostrar mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✅ Producto eliminado del albarán',
                    ), // 📢 Mensaje
                    backgroundColor: Colors.orange, // 🟠 Fondo naranja
                  ),
                );
              },
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

  // 💾 FUNCIÓN: Guardar albarán completo usando el servicio
  Future<void> _guardarAlbaranCompleto() async {
    // ✅ VALIDACIÓN: Datos generales
    final errorDatos = DatosGeneralesWidget.validarDatos(
      cliente: _clienteController.text,
      direccion: _direccionController.text,
      observaciones: _observacionesController.text,
    );

    if (errorDatos != null) {
      _mostrarError(errorDatos); // 🔔 Mostrar error
      return;
    }

    // ✅ VALIDACIÓN: Productos
    final errorProductos = ProductosService.validarDatosAlbaran(
      cliente: _clienteController.text.trim(),
      productos: productosSeleccionados,
    );

    if (errorProductos != null) {
      _mostrarError(errorProductos); // 🔔 Mostrar error
      return;
    }

    setState(() {
      _isLoading = true; // ⏳ Mostrar pantalla de carga
    });

    try {
      // 🌐 LLAMADA AL SERVICIO: Crear albarán completo
      final resultado = await ProductosService.crearAlbaranCompleto(
        cliente: _clienteController.text.trim(),
        direccionEntrega: _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        productos: productosSeleccionados,
      );

      if (resultado['exito'] == true) {
        // ✅ Si todo fue exitoso
        if (mounted) {
          // 🔔 ÉXITO: Mostrar mensaje con número de albarán
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${resultado['mensaje']} - Número: ${resultado['numeroAlbaran']}',
              ), // 📢 Mensaje
              backgroundColor: Colors.green, // 🟢 Fondo verde
            ),
          );
          Navigator.pop(context, true); // 🔙 Volver y notificar éxito
        }
      } else {
        // ❌ Si hubo error
        _mostrarError(
          resultado['error'] ?? 'Error desconocido',
        ); // 🔔 Mostrar error
      }
    } catch (e) {
      // 🚨 Si excepción no controlada
      _mostrarError('Error inesperado: $e'); // 🔔 Mostrar error
    } finally {
      // 🔄 Siempre ejecutar al final
      if (mounted) {
        setState(() {
          _isLoading = false; // ✅ Ocultar pantalla de carga
        });
      }
    }
  }

  // ⚠️ FUNCIÓN AUXILIAR: Mostrar mensajes de error
  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje), // 📢 Mensaje de error
          backgroundColor: Colors.red, // 🔴 Fondo rojo
        ),
      );
    }
  }
}
