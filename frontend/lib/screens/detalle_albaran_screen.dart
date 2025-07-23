import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/albaran.dart'; // 📋 Modelo de albarán
import '../models/producto_seleccionado.dart'; // 📦 Modelo producto seleccionado
import '../services/productos_service.dart'; // 🏢 Servicio productos
import '../services/impresion_service.dart'; // 🖨️ Servicio impresión
import '../services/api_service.dart'; // 🌐 Servicio API base
import '../widgets/edicion_albaran_dialog.dart'; // 📱 Widget diálogo edición
import '../widgets/detalle_productos_widget.dart'; // 📦 Widget gestión productos
// import '../widgets/gestion_estados_widget_backup.dart'; // 📊 Widget gestión estados
import '../widgets/botones_estado_widget.dart';

// 📱 PANTALLA: Detalle de albarán (VERSIÓN ACTUALIZADA)
class DetalleAlbaranScreen extends StatefulWidget {
  final Albaran albaran; // 📋 El albarán que vamos a mostrar

  const DetalleAlbaranScreen({
    super.key,
    required this.albaran, // 📋 Obligatorio pasar el albarán
  });

  @override
  State<DetalleAlbaranScreen> createState() => _DetalleAlbaranScreenState();
}

class _DetalleAlbaranScreenState extends State<DetalleAlbaranScreen> {
  // 📋 ESTADO: Datos locales del albarán (copia que podemos modificar)
  late Albaran albaranActual; // 📋 Copia modificable del albarán original

  // 📦 ESTADO: Lista de productos del albarán
  List<ProductoSeleccionado> productosAlbaran =
      []; // 📋 Lista productos del albarán
  bool isLoadingProductos = false; // ⏳ Indicador si está cargando productos
  String? errorProductos; // ❌ Mensaje de error si falla la carga

  // 🖨️ ESTADO: Control de impresión
  bool _imprimiendo = false; // ⏳ Indicador si está imprimiendo

  @override
  void initState() {
    super.initState(); // 🚀 Llamar al initState padre
    albaranActual = widget
        .albaran; // 📋 Copiar el albarán original a nuestra variable local
    _cargarProductosAlbaran(); // 📥 Cargar productos del albarán
  }

  // 📥 FUNCIÓN: Cargar productos del albarán desde la API
  Future<void> _cargarProductosAlbaran() async {
    setState(() {
      // 🔄 Actualizar la interfaz
      isLoadingProductos = true; // ⏳ Mostrar que está cargando
      errorProductos = null; // 🧹 Limpiar errores anteriores
    });

    try {
      // 🌐 LLAMADA AL SERVICIO: Obtener productos del albarán
      final productos = await ProductosService.cargarProductosAlbaran(
        albaranActual.id.toString(), // 🆔 Convertir ID a String para la API
      );

      setState(() {
        // 🔄 Actualizar la interfaz con los datos
        productosAlbaran = productos; // 📦 Guardar productos obtenidos
        isLoadingProductos = false; // ✅ Ya no está cargando
      });
    } catch (e) {
      // 🚨 Si hay error
      setState(() {
        // 🔄 Actualizar la interfaz con el error
        isLoadingProductos = false; // ✅ Ya no está cargando
        errorProductos = e.toString(); // ❌ Guardar mensaje de error
      });
    }
  }

  // 🔄 FUNCIÓN: Recargar albarán desde servidor (cuando cambia estado)
  Future<void> _recargarAlbaran() async {
    try {
      // 🌐 OBTENER: Albarán actualizado del servidor
      final albaranesActualizados = await ApiService.getAlbaranes();
      final albaranActualizado = albaranesActualizados.firstWhere(
        (a) => a.id == albaranActual.id,
        orElse: () => albaranActual, // 📋 Si no encuentra, mantener actual
      );

      setState(() {
        albaranActual = albaranActualizado; // 📋 Actualizar albarán local
      });
    } catch (e) {
      // 🚨 Error recargando, mantener datos actuales
      debugPrint('Error recargando albarán: $e');
    }
  }

  // ✏️ FUNCIÓN: Editar datos del albarán usando el widget modular
  Future<void> _editarDatosAlbaran() async {
    // 📱 MOSTRAR DIÁLOGO: Usando el widget modular
    final albaranEditado = await EdicionAlbaranDialog.mostrar(
      context: context, // 📱 Contexto actual
      albaranActual: albaranActual, // 📋 Albarán actual
    );

    if (albaranEditado != null) {
      // ✅ Si se editó exitosamente
      setState(() {
        // 🔄 Actualizar interfaz
        albaranActual = albaranEditado; // 📋 Actualizar con los nuevos datos
      });
    }
  }

  // 🖨️ FUNCIÓN: Imprimir albarán
  Future<void> _imprimirAlbaran() async {
    setState(() {
      _imprimiendo = true; // ⏳ Mostrar indicador de impresión
    });

    try {
      // 🖨️ LLAMADA AL SERVICIO: Imprimir albarán
      await ImpresionService.imprimirAlbaran(albaranActual.id);

      // ✅ ÉXITO: Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Albarán ${albaranActual.numeroAlbaran} enviado a impresión'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // ❌ ERROR: Mostrar mensaje de error
      if (mounted) {
        _mostrarError('Error imprimiendo albarán: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _imprimiendo = false; // ✅ Ocultar indicador de impresión
        });
      }
    }
  }

  // 💾 FUNCIÓN: Guardar PDF del albarán
  Future<void> _guardarPDF() async {
    try {
      // 💾 LLAMADA AL SERVICIO: Guardar PDF
      await ImpresionService.guardarPDF(
        albaranActual.id,
        'Albaran_${albaranActual.numeroAlbaran}',
      );

      // ✅ ÉXITO: Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '💾 PDF del albarán ${albaranActual.numeroAlbaran} guardado'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      // ❌ ERROR: Mostrar mensaje de error
      if (mounted) {
        _mostrarError('Error guardando PDF: $e');
      }
    }
  }

  // ⚠️ FUNCIÓN AUXILIAR: Mostrar mensajes de error
  void _mostrarError(String mensaje) {
    // 📝 Recibe el mensaje a mostrar
    if (mounted) {
      // 🔍 Verificar que el widget sigue activo
      ScaffoldMessenger.of(context).showSnackBar(
        // 📢 Mostrar mensaje emergente
        SnackBar(
          // 📢 Mensaje emergente
          content: Text(mensaje), // 📝 Texto del mensaje
          backgroundColor: Colors.red, // 🔴 Fondo rojo para errores
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📱 Estructura básica de la pantalla
      appBar: AppBar(
        // 📊 Barra superior
        title: Text(
          'Albarán ${albaranActual.numeroAlbaran}',
        ), // 🏷️ Título con número de albarán
        backgroundColor: Colors.blue, // 🔵 Fondo azul
        foregroundColor: const Color.fromARGB(255, 0, 0, 0), // ⚪ Texto blanco
        actions: [
          // 🔘 BOTONES: Acciones en la barra superior
          // 💾 BOTÓN: Guardar PDF
          IconButton(
            icon: const Icon(Icons.save_alt), // 💾 Icono guardar
            onPressed: _guardarPDF, // 👆 Acción guardar PDF
            tooltip: 'Guardar PDF', // 💡 Tooltip
          ),
          // 🖨️ BOTÓN: Imprimir
          IconButton(
            icon: _imprimiendo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print), // 🖨️ Icono imprimir
            onPressed:
                _imprimiendo ? null : _imprimirAlbaran, // 👆 Acción imprimir
            tooltip: 'Imprimir Albarán', // 💡 Tooltip
          ),
          // ✏️ BOTÓN: Editar
          IconButton(
            icon: const Icon(Icons.edit), // ✏️ Icono editar
            onPressed: _editarDatosAlbaran, // 👆 Acción editar
            tooltip: 'Editar Albarán', // 💡 Tooltip
          ),
        ],
      ),
      body: SingleChildScrollView(
        // 📜 Scroll vertical
        padding: const EdgeInsets.all(
          16.0,
        ), // 📏 Margen de 16 píxeles en todos lados
        child: Column(
          // 📋 Columna principal
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear contenido a la izquierda
          children: [
            // 🃏 TARJETA: Información principal del albarán
            _buildTarjetaInformacion(), // 🏗️ Construir tarjeta con datos del albarán
            const SizedBox(height: 16), // 📏 Espacio vertical

            // 📊 WIDGET MODULAR: Gestión de estados (NUEVO)
            // GestionEstadosWidget(
            //  albaranId: albaranActual.id, // 🆔 ID del albarán
            // estadoActual: albaranActual.estado, // 📊 Estado actual
            //numeroAlbaran:
            //  albaranActual.numeroAlbaran, // 📝 Número para mostrar
            // onEstadoCambiado:
            //  _recargarAlbaran, // 🔄 Callback cuando cambia estado
            //),
            const SizedBox(height: 16), // 📏 Espacio vertical

            // 📊 FILA: Información adicional + Botones de estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📝 INFORMACIÓN ADICIONAL (lado izquierdo)
                Expanded(
                  flex: 3, // 📏 Ocupa 3 partes del espacio disponible
                  child: _buildTarjetaDetalles(),
                ),
                const SizedBox(width: 16), // 📏 Espacio entre los dos elementos

                // 🔘 BOTONES DE ESTADO (lado derecho)
                Expanded(
                  flex: 2, // 📏 Ocupa 2 partes del espacio disponible
                  child: BotonesEstadoWidget(
                    albaran: albaranActual,
                    onEstadoCambiado: () {
                      _recargarAlbaran(); // 🔄 Recargar albarán cuando cambie estado
                      setState(() {
                        // 🔄 Forzar actualización de la interfaz
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // 📏 Espacio vertical

            // 🃏 WIDGET MODULAR: Productos del albarán
            DetalleProductosWidget(
              // 📦 Widget modular para gestión de productos
              albaranId: albaranActual.id, // 🆔 ID del albarán
              productosAlbaran: productosAlbaran, // 📋 Lista de productos
              isLoadingProductos: isLoadingProductos, // ⏳ Estado de carga
              errorProductos: errorProductos, // ❌ Error de carga
              onRecargarProductos:
                  _cargarProductosAlbaran, // 🔄 Callback para recargar
              onMostrarError: _mostrarError, // ⚠️ Callback para mostrar errores
            ),
          ],
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir tarjeta de información principal
  Widget _buildTarjetaInformacion() {
    return Card(
      // 🃏 Tarjeta con sombra
      elevation: 4, // 🌫️ Nivel de sombra
      child: Padding(
        // 📏 Margen interno
        padding: const EdgeInsets.all(16.0), // 📏 16 píxeles en todos lados
        child: Column(
          // 📋 Columna con información principal
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
          children: [
            // 🏷️ TÍTULO: Número del albarán
            Row(
              // ➡️ Fila con título y estado
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Albarán ${albaranActual.numeroAlbaran}', // 📝 Mostrar número
                  style: const TextStyle(
                    // 🎨 Estilo del texto
                    fontSize: 24, // 📏 Tamaño grande
                    fontWeight: FontWeight.bold, // 🔤 Negrita
                    color: Colors.blue, // 🔵 Color azul
                  ),
                ),
                // 📊 ESTADO con color
                Container(
                  // 📦 Contenedor para el estado con color
                  padding: const EdgeInsets.symmetric(
                    // 📏 Padding horizontal y vertical
                    horizontal: 12, // ↔️ 12 píxeles a los lados
                    vertical: 6, // ↕️ 6 píxeles arriba y abajo
                  ),
                  decoration: BoxDecoration(
                    // 🎨 Decoración del contenedor
                    color: _getEstadoColor(
                      albaranActual.estado,
                    ), // 🎨 Color según el estado
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // 🔄 Bordes redondeados
                  ),
                  child: Text(
                    // 📝 Texto del estado
                    albaranActual.estado
                        .toUpperCase(), // 🔤 Estado en mayúsculas
                    style: const TextStyle(
                      // 🎨 Estilo del texto
                      color: Colors.white, // ⚪ Texto blanco
                      fontWeight: FontWeight.bold, // 🔤 Negrita
                      fontSize: 12, // 📏 Tamaño pequeño
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // 📏 Espacio vertical
            // 👤 CLIENTE
            Text(
              'Cliente: ${albaranActual.cliente}', // 👤 Mostrar cliente
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ), // 🎨 Estilo
            ),
            const SizedBox(height: 8), // 📏 Espacio pequeño
            // 📅 FECHA DE CREACIÓN
            Text(
              'Creado: ${_formatearFecha(albaranActual.fechaCreacion)}', // 📅 Mostrar fecha
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ), // 🎨 Estilo gris
            ),
          ],
        ),
      ),
    );
  }

  // 🏗️ MÉTODO: Construir tarjeta de detalles adicionales
  Widget _buildTarjetaDetalles() {
    return Card(
      // 🃏 Tarjeta con sombra
      elevation: 4, // 🌫️ Nivel de sombra
      child: Padding(
        // 📏 Margen interno
        padding: const EdgeInsets.all(16.0), // 📏 16 píxeles en todos lados
        child: Column(
          // 📋 Columna con detalles adicionales
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
          children: [
            // 🏷️ TÍTULO: Detalles adicionales
            const Text(
              'Información Adicional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12), // 📏 Espacio vertical
            // 📍 DIRECCIÓN DE ENTREGA
            _buildInfoRow(
              // 📝 Función auxiliar para mostrar información
              'Dirección de entrega:', // 🏷️ Etiqueta
              albaranActual.direccionEntrega ??
                  'No especificada', // 📍 Dirección o texto por defecto
            ),
            const SizedBox(height: 8), // 📏 Espacio vertical
            // 📝 OBSERVACIONES
            _buildInfoRow(
              'Observaciones:', // 🏷️ Etiqueta
              albaranActual.observaciones ??
                  'Sin observaciones', // 📝 Observaciones o texto por defecto
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 FUNCIÓN AUXILIAR: Obtener color según el estado
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      // 🔄 Convertir a minúsculas para comparar
      case 'pendiente':
        return Colors.orange; // 🟠 Naranja para pendiente
      case 'enviado':
        return Colors.blue; // 🔵 Azul para enviado
      case 'entregado':
        return Colors.green; // 🟢 Verde para entregado
      default:
        return Colors.grey; // ⚫ Gris para estados desconocidos
    }
  }

  // 📝 FUNCIÓN AUXILIAR: Crear fila de información
  Widget _buildInfoRow(String label, String value) {
    return Column(
      // 📋 Columna vertical
      crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
      children: [
        Text(
          // 🏷️ Etiqueta
          label,
          style: const TextStyle(
            // 🎨 Estilo de la etiqueta
            fontWeight: FontWeight.bold, // 🔤 Negrita
            color: Colors.grey, // ⚫ Color gris
            fontSize: 14, // 📏 Tamaño pequeño
          ),
        ),
        const SizedBox(height: 2), // 📏 Espacio muy pequeño
        Text(
          // 📝 Valor
          value,
          style: const TextStyle(
            // 🎨 Estilo del valor
            fontSize: 16, // 📏 Tamaño normal
          ),
        ),
      ],
    );
  }

  // 📅 FUNCIÓN AUXILIAR: Formatear fecha
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/' + // 📅 Día con 2 dígitos
        '${fecha.month.toString().padLeft(2, '0')}/' + // 📅 Mes con 2 dígitos
        '${fecha.year} ' + // 📅 Año
        '${fecha.hour.toString().padLeft(2, '0')}:' + // 🕐 Hora con 2 dígitos
        '${fecha.minute.toString().padLeft(2, '0')}'; // 🕐 Minutos con 2 dígitos
  }
}
