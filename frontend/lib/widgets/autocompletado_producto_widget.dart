import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import 'dart:async'; // ⏰ Para Timer (debounce)
import '../models/producto_disponible.dart'; // 📦 Modelo producto
import '../services/busqueda_service.dart'; // 🔍 Servicio búsqueda

// 🔍 WIDGET: Autocompletado inteligente para productos
class AutocompletadoProductoWidget extends StatefulWidget {
  final Function(ProductoDisponible)
  onProductoSeleccionado; // 🔗 Callback producto elegido
  final String? hintText; // 💡 Texto de ayuda opcional
  final String? labelText; // 🏷️ Etiqueta opcional

  const AutocompletadoProductoWidget({
    super.key,
    required this.onProductoSeleccionado, // 🔗 Callback obligatorio
    this.hintText =
        'Buscar por referencia o descripción...', // 💡 Hint por defecto
    this.labelText = 'Buscar Producto', // 🏷️ Label por defecto
  });

  @override
  State<AutocompletadoProductoWidget> createState() =>
      _AutocompletadoProductoWidgetState();
}

class _AutocompletadoProductoWidgetState
    extends State<AutocompletadoProductoWidget> {
  final TextEditingController _controller =
      TextEditingController(); // 🔗 Controlador del campo
  final FocusNode _focusNode = FocusNode(); // 🎯 Control del foco
  Timer? _debounceTimer; // ⏰ Timer para retrasar búsqueda

  List<ProductoDisponible> _sugerencias =
      []; // 📋 Lista de productos encontrados
  bool _mostrandoSugerencias = false; // 👁️ Si mostrar panel sugerencias
  bool _cargandoBusqueda = false; // ⏳ Indicador de búsqueda en curso
  String _ultimaBusqueda = ''; // 📝 Última búsqueda realizada

  @override
  void initState() {
    super.initState();
    // 👂 LISTENER: Detectar cambios en el texto
    _controller.addListener(_onTextChanged);

    // 👂 LISTENER: Detectar cambios en el foco
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    // 🗑️ Limpiar recursos
    _debounceTimer?.cancel(); // ⏰ Cancelar timer si existe
    _controller.dispose(); // 🧹 Liberar controlador
    _focusNode.dispose(); // 🧹 Liberar focus node
    super.dispose();
  }

  // 📝 FUNCIÓN: Detectar cambios en el texto del campo
  void _onTextChanged() {
    final query = _controller.text.trim(); // 📝 Obtener texto limpio

    // ⏰ DEBOUNCE: Cancelar búsqueda anterior y programar nueva
    _debounceTimer?.cancel(); // ⏰ Cancelar timer previo
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // ⏰ Esperar 300ms sin cambios
      if (query != _ultimaBusqueda) {
        // 🔍 Solo buscar si el texto cambió
        _realizarBusqueda(query); // 🔍 Ejecutar búsqueda
      }
    });
  }

  // 🎯 FUNCIÓN: Detectar cambios en el foco del campo
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // 🎯 Si pierde el foco
      // ⏱️ Esperar un poco antes de ocultar sugerencias (por si hacen clic en una)
      Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          // 🔍 Verificar que widget sigue activo
          setState(() {
            _mostrandoSugerencias = false; // 👁️ Ocultar panel sugerencias
          });
        }
      });
    }
  }

  // 🔍 FUNCIÓN: Realizar búsqueda de productos
  Future<void> _realizarBusqueda(String query) async {
    _ultimaBusqueda = query; // 📝 Recordar última búsqueda

    if (query.length < 2) {
      // 🔍 Si query muy corto
      setState(() {
        _sugerencias = []; // 📋 Limpiar sugerencias
        _mostrandoSugerencias = false; // 👁️ Ocultar panel
        _cargandoBusqueda = false; // ⏳ No está cargando
      });
      return; // 🛑 Salir sin buscar
    }

    setState(() {
      _cargandoBusqueda = true; // ⏳ Indicar que está buscando
      _mostrandoSugerencias = true; // 👁️ Mostrar panel (aunque sea vacío)
    });

    try {
      // 🌐 LLAMADA AL SERVICIO: Buscar productos
      final productos = await BusquedaService.buscarProductos(query);

      if (mounted && query == _ultimaBusqueda) {
        // 🔍 Verificar que sigue siendo la búsqueda actual
        setState(() {
          _sugerencias = productos; // 📋 Actualizar sugerencias
          _cargandoBusqueda = false; // ⏳ Terminar indicador carga
        });
      }
    } catch (e) {
      // 🚨 Error en la búsqueda
      if (mounted) {
        // 🔍 Verificar que widget sigue activo
        setState(() {
          _sugerencias = []; // 📋 Limpiar sugerencias
          _cargandoBusqueda = false; // ⏳ Terminar indicador carga
        });
        // 🔔 Mostrar error al usuario (opcional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en búsqueda: $e'), // 📢 Mensaje de error
            backgroundColor: Colors.red, // 🔴 Fondo rojo
          ),
        );
      }
    }
  }

  // ✅ FUNCIÓN: Seleccionar producto de las sugerencias
  void _seleccionarProducto(ProductoDisponible producto) {
    setState(() {
      _controller.text =
          '${producto.referencia} - ${producto.descripcion}'; // 📝 Mostrar producto seleccionado
      _mostrandoSugerencias = false; // 👁️ Ocultar sugerencias
    });
    _focusNode.unfocus(); // 🎯 Quitar foco del campo
    widget.onProductoSeleccionado(
      producto,
    ); // 🔗 Notificar selección al widget padre
  }

  // ➕ FUNCIÓN: Mostrar diálogo para crear producto nuevo
  void _mostrarDialogoCrearProducto() {
    final referenciaController = TextEditingController(
      text: _controller.text.trim(),
    ); // 📝 Pre-rellenar con búsqueda
    final descripcionController =
        TextEditingController(); // 📝 Descripción vacía
    final precioController = TextEditingController(); // 💰 Precio vacío
    final stockController = TextEditingController(
      text: '0',
    ); // 📊 Stock inicial 0
    String usoSeleccionado = 'produccion'; // 🎯 Uso por defecto

    showDialog(
      // 📱 Mostrar diálogo modal
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // 🔄 Builder con estado local
          builder: (context, setDialogState) {
            return AlertDialog(
              // 📱 Diálogo de alerta
              title: const Text('Crear Nuevo Producto'), // 🏷️ Título
              content: SingleChildScrollView(
                // 📜 Scroll si contenido largo
                child: Column(
                  // 📋 Columna con campos
                  mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
                  children: [
                    // 📝 CAMPO: Referencia
                    TextFormField(
                      controller:
                          referenciaController, // 🔗 Controlador referencia
                      decoration: const InputDecoration(
                        labelText: 'Referencia *', // 🏷️ Etiqueta obligatoria
                        hintText: 'REF001, TORN-M6, etc.', // 💡 Ejemplos
                        prefixIcon: Icon(Icons.tag), // 🏷️ Icono tag
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      textCapitalization: TextCapitalization
                          .characters, // 🔤 Mayúsculas automáticas
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 📝 CAMPO: Descripción
                    TextFormField(
                      controller:
                          descripcionController, // 🔗 Controlador descripción
                      decoration: const InputDecoration(
                        labelText: 'Descripción *', // 🏷️ Etiqueta obligatoria
                        hintText:
                            'Descripción detallada del producto', // 💡 Ayuda
                        prefixIcon: Icon(
                          Icons.description,
                        ), // 📝 Icono descripción
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      maxLines: 2, // 📏 Permitir 2 líneas
                      textCapitalization: TextCapitalization
                          .sentences, // 🔤 Primera letra mayúscula
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 🎯 DROPDOWN: Uso del producto
                    DropdownButtonFormField<String>(
                      value: usoSeleccionado, // 🎯 Valor seleccionado
                      decoration: const InputDecoration(
                        labelText: 'Uso del Producto *', // 🏷️ Etiqueta
                        prefixIcon: Icon(Icons.category), // 🎯 Icono categoría
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      items: BusquedaService.obtenerUsosDisponibles().map((
                        uso,
                      ) {
                        // 🗂️ Mapear usos disponibles
                        return DropdownMenuItem<String>(
                          value: uso['valor'], // 🎯 Valor del item
                          child: Text(uso['etiqueta']!), // 📝 Texto mostrado
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // 👆 Cuando cambie selección
                        setDialogState(() {
                          // 🔄 Actualizar estado diálogo
                          usoSeleccionado =
                              newValue ?? 'produccion'; // 🎯 Guardar nuevo uso
                        });
                      },
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 💰 CAMPO: Precio (opcional)
                    TextFormField(
                      controller: precioController, // 🔗 Controlador precio
                      decoration: const InputDecoration(
                        labelText: 'Precio', // 🏷️ Etiqueta (opcional)
                        hintText: '0.00', // 💡 Formato ejemplo
                        prefixIcon: Icon(Icons.euro), // 💰 Icono euro
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ), // ⌨️ Teclado números decimales
                    ),
                    const SizedBox(height: 16), // 📏 Espacio
                    // 📊 CAMPO: Stock inicial
                    TextFormField(
                      controller: stockController, // 🔗 Controlador stock
                      decoration: const InputDecoration(
                        labelText: 'Stock Inicial', // 🏷️ Etiqueta
                        hintText: '0', // 💡 Valor por defecto
                        prefixIcon: Icon(
                          Icons.inventory,
                        ), // 📊 Icono inventario
                        border: OutlineInputBorder(), // 🔲 Borde
                      ),
                      keyboardType: TextInputType.number, // ⌨️ Teclado numérico
                    ),
                  ],
                ),
              ),
              actions: [
                // 🔘 Botones del diálogo
                TextButton(
                  // ❌ Botón cancelar
                  onPressed: () {
                    // 👆 Cerrar sin crear
                    Navigator.of(context).pop(); // 🔙 Cerrar diálogo
                  },
                  child: const Text('Cancelar'), // 🏷️ Texto botón
                ),
                TextButton(
                  // ➕ Botón crear
                  onPressed: () => _crearProductoNuevo(
                    // 👆 Función crear producto
                    referenciaController.text, // 📝 Referencia
                    descripcionController.text, // 📝 Descripción
                    usoSeleccionado, // 🎯 Uso seleccionado
                    precioController.text, // 💰 Precio
                    stockController.text, // 📊 Stock
                  ),
                  child: const Text('Crear'), // 🏷️ Texto botón
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ➕ FUNCIÓN: Crear producto nuevo con validaciones
  Future<void> _crearProductoNuevo(
    String referencia, // 📝 Referencia del producto
    String descripcion, // 📝 Descripción del producto
    String uso, // 🎯 Uso del producto
    String precioTexto, // 💰 Precio como texto
    String stockTexto, // 📊 Stock como texto
  ) async {
    // ✅ VALIDACIONES: Campos obligatorios
    final errorReferencia = BusquedaService.validarReferencia(referencia);
    if (errorReferencia != null) {
      _mostrarError(errorReferencia); // ⚠️ Mostrar error referencia
      return; // 🛑 Salir sin crear
    }

    final errorDescripcion = BusquedaService.validarDescripcion(descripcion);
    if (errorDescripcion != null) {
      _mostrarError(errorDescripcion); // ⚠️ Mostrar error descripción
      return; // 🛑 Salir sin crear
    }

    // 🔢 CONVERSIONES: Texto a números
    final precio = precioTexto.trim().isEmpty
        ? null
        : double.tryParse(precioTexto); // 💰 Convertir precio
    if (precioTexto.trim().isNotEmpty && precio == null) {
      _mostrarError('El precio debe ser un número válido'); // ⚠️ Error precio
      return; // 🛑 Salir sin crear
    }

    final stock =
        int.tryParse(stockTexto) ?? 0; // 📊 Convertir stock (por defecto 0)
    if (stock < 0) {
      _mostrarError('El stock no puede ser negativo'); // ⚠️ Error stock
      return; // 🛑 Salir sin crear
    }

    try {
      Navigator.of(context).pop(); // 🔙 Cerrar diálogo antes de crear

      // 🔔 INDICADOR: Mostrar que se está creando
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Creando producto...'), // 📢 Mensaje creando
          backgroundColor: Colors.blue, // 🔵 Fondo azul
        ),
      );

      // 🌐 LLAMADA AL SERVICIO: Crear producto
      final productoCreado = await BusquedaService.crearProducto(
        referencia: referencia, // 📝 Referencia validada
        descripcion: descripcion, // 📝 Descripción validada
        uso: uso, // 🎯 Uso seleccionado
        precio: precio, // 💰 Precio convertido
        stockActual: stock, // 📊 Stock convertido
      );

      if (productoCreado != null) {
        // ✅ Si producto creado exitosamente
        // 🔔 ÉXITO: Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Producto ${productoCreado.referencia} creado correctamente',
            ), // 📢 Mensaje éxito
            backgroundColor: Colors.green, // 🟢 Fondo verde
          ),
        );

        // ✅ SELECCIONAR: Producto recién creado automáticamente
        _seleccionarProducto(productoCreado); // 🔗 Seleccionar producto nuevo
      }
    } catch (e) {
      // 🚨 Error creando producto
      _mostrarError('Error creando producto: $e'); // ⚠️ Mostrar error
    }
  }

  // ⚠️ FUNCIÓN AUXILIAR: Mostrar mensajes de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      // 🔔 Mostrar mensaje
      SnackBar(
        content: Text(mensaje), // 📢 Mensaje de error
        backgroundColor: Colors.red, // 🔴 Fondo rojo
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Construir la interfaz
    return Column(
      // 📋 Columna principal
      crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
      children: [
        // 📝 CAMPO: Búsqueda principal
        TextFormField(
          controller: _controller, // 🔗 Conectar controlador
          focusNode: _focusNode, // 🎯 Conectar focus node
          decoration: InputDecoration(
            labelText: widget.labelText, // 🏷️ Etiqueta personalizable
            hintText: widget.hintText, // 💡 Ayuda personalizable
            prefixIcon: const Icon(Icons.search), // 🔍 Icono búsqueda
            border: const OutlineInputBorder(), // 🔲 Borde
            suffixIcon:
                _cargandoBusqueda // 🔄 Icono dinámico en el final
                ? const SizedBox(
                    // ⏳ Si cargando: ruedita pequeña
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _controller
                      .text
                      .isNotEmpty // 🧹 Si hay texto: botón limpiar
                ? IconButton(
                    icon: const Icon(Icons.clear), // ❌ Icono limpiar
                    onPressed: () {
                      // 👆 Limpiar campo
                      _controller.clear(); // 🧹 Vaciar controlador
                      setState(() {
                        _sugerencias = []; // 📋 Limpiar sugerencias
                        _mostrandoSugerencias = false; // 👁️ Ocultar panel
                      });
                    },
                  )
                : null, // ❌ Sin texto: sin icono
          ),
        ),

        // 📋 PANEL: Sugerencias (solo si hay que mostrar)
        if (_mostrandoSugerencias)
          Container(
            // 📦 Contenedor del panel
            margin: const EdgeInsets.only(top: 4), // 📏 Pequeño margen superior
            decoration: BoxDecoration(
              // 🎨 Decoración del panel
              color: Colors.white, // ⚪ Fondo blanco
              border: Border.all(color: Colors.grey.shade300), // 🔲 Borde gris
              borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
              boxShadow: [
                // 🌫️ Sombra del panel
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // ⚫ Sombra sutil
                  blurRadius: 4, // 🌫️ Difuminado
                  offset: const Offset(0, 2), // 📏 Desplazamiento sombra
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 200,
            ), // 📏 Altura máxima del panel
            child:
                _buildPanelSugerencias(), // 🏗️ Construir contenido del panel
          ),
      ],
    );
  }

  // 🏗️ MÉTODO: Construir panel de sugerencias
  Widget _buildPanelSugerencias() {
    if (_cargandoBusqueda) {
      // ⏳ Si está buscando
      return const Padding(
        // 📏 Panel con indicador carga
        padding: EdgeInsets.all(16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
            children: [
              SizedBox(
                // ⏳ Ruedita pequeña
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8), // 📏 Espacio
              Text('Buscando...'), // 📝 Mensaje buscando
            ],
          ),
        ),
      );
    }

    if (_sugerencias.isEmpty && _controller.text.trim().length >= 2) {
      // 📋 Si no hay resultados
      return Padding(
        // 📏 Panel con opción crear
        padding: const EdgeInsets.all(8),
        child: Column(
          // 📋 Columna con opciones
          mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo
          children: [
            // 📝 MENSAJE: No encontrado
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'No se encontraron productos', // 📝 Mensaje no encontrado
                style: TextStyle(color: Colors.grey), // ⚫ Color gris
              ),
            ),
            // ➕ OPCIÓN: Crear nuevo
            ListTile(
              leading: const Icon(
                Icons.add,
                color: Colors.green,
              ), // ➕ Icono verde
              title: Text(
                'Crear "${_controller.text.trim()}"',
              ), // 📝 Texto crear con búsqueda
              subtitle: const Text(
                'Añadir como producto nuevo',
              ), // 💡 Explicación
              onTap: _mostrarDialogoCrearProducto, // 👆 Mostrar diálogo crear
            ),
          ],
        ),
      );
    }

    // 📋 LISTA: Sugerencias encontradas + opción crear
    return ListView(
      // 📋 Lista desplazable
      shrinkWrap: true, // 📏 Ajustar al contenido
      padding: const EdgeInsets.all(4), // 📏 Padding pequeño
      children: [
        // 📋 PRODUCTOS: Sugerencias encontradas
        ..._sugerencias.map((producto) {
          // 🗂️ Mapear cada producto encontrado
          return ListTile(
            leading: CircleAvatar(
              // 🔵 Círculo con inicial
              backgroundColor: Colors.blue, // 🔵 Fondo azul
              child: Text(
                producto.referencia.substring(
                  0,
                  1,
                ), // 📝 Primera letra referencia
                style: const TextStyle(color: Colors.white), // ⚪ Texto blanco
              ),
            ),
            title: Text(
              '${producto.referencia} - ${producto.descripcion}', // 📝 Ref + descripción
              style: const TextStyle(fontWeight: FontWeight.bold), // 🔤 Negrita
            ),
            subtitle: Text(
              'Stock: ${producto.stockActual}',
            ), // 📊 Mostrar stock
            onTap: () =>
                _seleccionarProducto(producto), // 👆 Seleccionar producto
          );
        }).toList(),

        // ➕ OPCIÓN: Crear nuevo (siempre al final)
        if (_controller.text.trim().length >=
            2) // 🔍 Solo si hay texto suficiente
          Container(
            // 📦 Contenedor diferenciado
            decoration: BoxDecoration(
              // 🎨 Decoración especial
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ), // 🔲 Línea separadora
            ),
            child: ListTile(
              leading: const Icon(
                Icons.add,
                color: Colors.green,
              ), // ➕ Icono verde
              title: Text(
                'Crear "${_controller.text.trim()}"',
              ), // 📝 Texto crear
              subtitle: const Text(
                'Añadir como producto nuevo',
              ), // 💡 Explicación
              onTap: _mostrarDialogoCrearProducto, // 👆 Mostrar diálogo crear
            ),
          ),
      ],
    );
  }
}
