import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter
import '../models/albaran.dart'; // 📋 Modelo de albarán
import '../services/productos_service.dart'; // 🏢 Servicio productos

// 📱 WIDGET: Diálogo para editar datos del albarán
class EdicionAlbaranDialog {
  // 📱 FUNCIÓN ESTÁTICA: Mostrar diálogo de edición
  static Future<Albaran?> mostrar({
    required BuildContext context, // 📱 Contexto de la pantalla
    required Albaran albaranActual, // 📋 Albarán actual a editar
  }) async {
    // 🔗 CONTROLADORES: Para capturar texto de los campos
    final clienteController = TextEditingController(
      text: albaranActual.cliente,
    ); // 👤 Pre-rellenar cliente
    final direccionController = TextEditingController(
      text: albaranActual.direccionEntrega ?? '',
    ); // 📍 Pre-rellenar dirección
    final observacionesController = TextEditingController(
      text: albaranActual.observaciones ?? '',
    ); // 📝 Pre-rellenar observaciones

    // 📱 MOSTRAR DIÁLOGO: Devuelve el albarán editado o null si se cancela
    final resultado = await showDialog<Albaran?>(
      context: context, // 📱 Contexto actual
      builder: (BuildContext context) {
        // 🏗️ Constructor del diálogo
        return AlertDialog(
          // 📱 Diálogo de alerta
          title: const Text('Editar Albarán'), // 🏷️ Título del diálogo
          content: SizedBox(
            // 📦 Contenedor con tamaño fijo
            width: 400, // 📏 Ancho fijo del diálogo
            child: Column(
              // 📋 Columna con los campos
              mainAxisSize: MainAxisSize.min, // 📏 Tamaño mínimo necesario
              children: [
                // 👤 CAMPO: Cliente
                TextFormField(
                  controller: clienteController, // 🔗 Conectar controlador
                  decoration: const InputDecoration(
                    // 🎨 Decoración del campo
                    labelText:
                        'Cliente *', // 🏷️ Etiqueta con asterisco (obligatorio)
                    prefixIcon: Icon(Icons.person), // 👤 Icono de persona
                    border: OutlineInputBorder(), // 🔲 Borde rectangular
                  ),
                  textCapitalization: TextCapitalization
                      .words, // 🔤 Primera letra de cada palabra en mayúscula
                ),
                const SizedBox(height: 16), // 📏 Espacio vertical entre campos
                // 📍 CAMPO: Dirección
                TextFormField(
                  controller: direccionController, // 🔗 Conectar controlador
                  decoration: const InputDecoration(
                    // 🎨 Decoración del campo
                    labelText: 'Dirección de Entrega', // 🏷️ Etiqueta
                    prefixIcon: Icon(
                      Icons.location_on,
                    ), // 📍 Icono de ubicación
                    border: OutlineInputBorder(), // 🔲 Borde rectangular
                  ),
                  maxLines: 2, // 📏 Permitir hasta 2 líneas
                  textCapitalization: TextCapitalization
                      .sentences, // 🔤 Primera letra de cada oración en mayúscula
                ),
                const SizedBox(height: 16), // 📏 Espacio vertical entre campos
                // 📝 CAMPO: Observaciones
                TextFormField(
                  controller:
                      observacionesController, // 🔗 Conectar controlador
                  decoration: const InputDecoration(
                    // 🎨 Decoración del campo
                    labelText: 'Observaciones', // 🏷️ Etiqueta
                    prefixIcon: Icon(Icons.note), // 📝 Icono de nota
                    border: OutlineInputBorder(), // 🔲 Borde rectangular
                  ),
                  maxLines: 3, // 📏 Permitir hasta 3 líneas
                  textCapitalization: TextCapitalization
                      .sentences, // 🔤 Primera letra de cada oración en mayúscula
                ),
              ],
            ),
          ),
          actions: [
            // 🔘 Botones del diálogo
            TextButton(
              // ❌ Botón cancelar
              onPressed: () {
                // 👆 Acción al pulsar cancelar
                _limpiarControladores(
                  clienteController,
                  direccionController,
                  observacionesController,
                ); // 🧹 Limpiar memoria
                Navigator.of(context).pop(null); // 🔙 Cerrar sin guardar
              },
              child: const Text('Cancelar'), // 🏷️ Texto del botón
            ),
            TextButton(
              // ✅ Botón guardar
              onPressed: () => _guardarCambios(
                // 👆 Acción al pulsar guardar
                context, // 📱 Contexto
                albaranActual, // 📋 Albarán original
                clienteController, // 🔗 Controlador cliente
                direccionController, // 🔗 Controlador dirección
                observacionesController, // 🔗 Controlador observaciones
              ),
              child: const Text('Guardar'), // 🏷️ Texto del botón
            ),
          ],
        );
      },
    );

    return resultado; // 📋 Devolver el albarán editado o null
  }

  // 💾 FUNCIÓN PRIVADA: Guardar cambios del albarán
  static Future<void> _guardarCambios(
    BuildContext context, // 📱 Contexto para mostrar mensajes
    Albaran albaranActual, // 📋 Albarán original
    TextEditingController clienteController, // 🔗 Controlador cliente
    TextEditingController direccionController, // 🔗 Controlador dirección
    TextEditingController
    observacionesController, // 🔗 Controlador observaciones
  ) async {
    // ✅ VALIDACIÓN: Cliente obligatorio
    if (clienteController.text.trim().isEmpty) {
      // 🔍 Verificar que no esté vacío
      _mostrarError(context, 'El cliente es obligatorio'); // ⚠️ Mostrar error
      return; // 🛑 Salir sin guardar
    }

    try {
      // 🌐 LLAMADA AL SERVICIO: Actualizar albarán en la base de datos
      final exito = await ProductosService.actualizarAlbaran(
        albaranId: albaranActual.id, // 🆔 ID del albarán
        cliente: clienteController.text.trim(), // 👤 Cliente limpio
        direccionEntrega: direccionController.text.trim().isEmpty
            ? null
            : direccionController.text.trim(), // 📍 Dirección
        observaciones: observacionesController.text.trim().isEmpty
            ? null
            : observacionesController.text.trim(), // 📝 Observaciones
      );

      if (exito) {
        // ✅ Si la actualización fue exitosa
        // 📋 CREAR: Nuevo objeto albarán con datos actualizados
        final albaranEditado = Albaran(
          id: albaranActual.id, // 🆔 Mantener mismo ID
          numeroAlbaran:
              albaranActual.numeroAlbaran, // 📝 Mantener mismo número
          cliente: clienteController.text.trim(), // 👤 Nuevo cliente
          direccionEntrega: direccionController.text.trim().isEmpty
              ? null
              : direccionController.text.trim(), // 📍 Nueva dirección
          estado: albaranActual.estado, // 📊 Mantener mismo estado
          fechaCreacion: albaranActual.fechaCreacion, // 📅 Mantener misma fecha
          observaciones: observacionesController.text.trim().isEmpty
              ? null
              : observacionesController.text.trim(), // 📝 Nuevas observaciones
        );

        // 🧹 LIMPIAR: Controladores
        _limpiarControladores(
          clienteController,
          direccionController,
          observacionesController,
        ); // 🧹 Liberar memoria

        // 🔔 MOSTRAR: Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // 📢 Mensaje emergente
            content: Text(
              '✅ Albarán actualizado correctamente',
            ), // 📝 Texto de éxito
            backgroundColor: Colors.green, // 🟢 Fondo verde
          ),
        );

        Navigator.of(
          context,
        ).pop(albaranEditado); // 🔙 Cerrar diálogo y devolver albarán editado
      } else {
        // ❌ Si hubo error
        _mostrarError(
          context,
          'Error al actualizar el albarán',
        ); // ⚠️ Mostrar error
      }
    } catch (e) {
      // 🚨 Si hay excepción
      _mostrarError(
        context,
        'Error de conexión: $e',
      ); // ⚠️ Mostrar error de conexión
    }
  }

  // 🧹 FUNCIÓN PRIVADA: Limpiar controladores
  static void _limpiarControladores(
    TextEditingController clienteController, // 🔗 Controlador cliente
    TextEditingController direccionController, // 🔗 Controlador dirección
    TextEditingController
    observacionesController, // 🔗 Controlador observaciones
  ) {
    clienteController.dispose(); // 🧹 Liberar controlador cliente
    direccionController.dispose(); // 🧹 Liberar controlador dirección
    observacionesController.dispose(); // 🧹 Liberar controlador observaciones
  }

  // ⚠️ FUNCIÓN PRIVADA: Mostrar errores
  static void _mostrarError(BuildContext context, String mensaje) {
    // 📝 Recibe contexto y mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      // 📢 Mostrar mensaje emergente
      SnackBar(
        // 📢 Mensaje emergente
        content: Text(mensaje), // 📝 Texto del error
        backgroundColor: Colors.red, // 🔴 Fondo rojo para errores
      ),
    );
  }
}
