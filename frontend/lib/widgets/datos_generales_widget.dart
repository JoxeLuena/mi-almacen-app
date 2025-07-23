import 'package:flutter/material.dart'; // 🎨 Widgets de Flutter

// 📋 WIDGET: Formulario de datos generales del albarán
// Similar a un UserControl en Visual Basic
class DatosGeneralesWidget extends StatelessWidget {
  final TextEditingController
  clienteController; // 🔗 Controlador del campo cliente
  final TextEditingController
  direccionController; // 🔗 Controlador del campo dirección
  final TextEditingController
  observacionesController; // 🔗 Controlador del campo observaciones

  // 🏗️ CONSTRUCTOR: Recibe los controladores desde la pantalla principal
  const DatosGeneralesWidget({
    super.key,
    required this.clienteController, // 👤 Controlador cliente obligatorio
    required this.direccionController, // 📍 Controlador dirección obligatorio
    required this.observacionesController, // 📝 Controlador observaciones obligatorio
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Construir la interfaz
    return Card(
      // 🃏 Tarjeta con sombra
      elevation: 4, // 🌫️ Nivel de sombra
      child: Padding(
        // 📏 Margen interno
        padding: const EdgeInsets.all(16), // 📏 16 píxeles en todos lados
        child: Column(
          // 📋 Columna vertical con campos
          crossAxisAlignment:
              CrossAxisAlignment.start, // ⬅️ Alinear contenido a la izquierda
          children: [
            // 🏷️ TÍTULO de la sección
            const Text(
              'Información General', // 📝 Texto del título
              style: TextStyle(
                fontSize: 20, // 📏 Tamaño de fuente grande
                fontWeight: FontWeight.bold, // 🔤 Texto en negrita
                color: Colors.blue, // 🔵 Color azul corporativo
              ),
            ),
            const SizedBox(
              height: 16,
            ), // 📏 Espacio vertical entre título y campos
            // 👤 CAMPO: Cliente (obligatorio)
            TextFormField(
              controller: clienteController, // 🔗 Conectar con controlador
              decoration: const InputDecoration(
                labelText:
                    'Cliente *', // 🏷️ Etiqueta con asterisco (obligatorio)
                hintText: 'Nombre del cliente', // 💡 Texto de ayuda
                prefixIcon: Icon(Icons.person), // 👤 Icono de persona
                border: OutlineInputBorder(), // 🔲 Borde rectangular
              ),
              textCapitalization: TextCapitalization
                  .words, // 🔤 Primera letra de cada palabra en mayúscula
              validator: (value) {
                // ✅ Validación del campo
                if (value == null || value.trim().isEmpty) {
                  return 'El cliente es obligatorio'; // ⚠️ Mensaje de error
                }
                return null; // ✅ Campo válido
              },
            ),
            const SizedBox(height: 16), // 📏 Espacio entre campos
            // 📍 CAMPO: Dirección de entrega (opcional)
            TextFormField(
              controller: direccionController, // 🔗 Conectar con controlador
              decoration: const InputDecoration(
                labelText:
                    'Dirección de Entrega', // 🏷️ Etiqueta sin asterisco (opcional)
                hintText: 'Dirección completa (opcional)', // 💡 Texto de ayuda
                prefixIcon: Icon(Icons.location_on), // 📍 Icono de ubicación
                border: OutlineInputBorder(), // 🔲 Borde rectangular
              ),
              maxLines: 2, // 📏 Permitir hasta 2 líneas de texto
              textCapitalization: TextCapitalization
                  .sentences, // 🔤 Primera letra de cada oración en mayúscula
            ),
            const SizedBox(height: 16), // 📏 Espacio entre campos
            // 📝 CAMPO: Observaciones generales (opcional)
            TextFormField(
              controller:
                  observacionesController, // 🔗 Conectar con controlador
              decoration: const InputDecoration(
                labelText: 'Observaciones', // 🏷️ Etiqueta
                hintText:
                    'Notas adicionales sobre el albarán (opcional)', // 💡 Texto de ayuda
                prefixIcon: Icon(Icons.note), // 📝 Icono de nota
                border: OutlineInputBorder(), // 🔲 Borde rectangular
              ),
              maxLines: 3, // 📏 Permitir hasta 3 líneas de texto
              textCapitalization: TextCapitalization
                  .sentences, // 🔤 Primera letra de cada oración en mayúscula
            ),

            // 💡 INFORMACIÓN: Ayuda sobre campos obligatorios
            const SizedBox(height: 12), // 📏 Espacio pequeño
            Row(
              // ➡️ Fila horizontal
              children: [
                const Icon(
                  // ℹ️ Icono de información
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8), // 📏 Espacio horizontal
                Text(
                  'Los campos marcados con * son obligatorios', // 📝 Mensaje informativo
                  style: TextStyle(
                    fontSize: 12, // 📏 Tamaño de fuente pequeño
                    color: Colors.grey.shade600, // ⚫ Color gris
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ MÉTODO: Validar todos los campos del formulario
  static String? validarDatos({
    required String cliente, // 👤 Cliente a validar
    String? direccion, // 📍 Dirección (opcional)
    String? observaciones, // 📝 Observaciones (opcional)
  }) {
    // 🔍 VALIDACIÓN: Cliente obligatorio
    if (cliente.trim().isEmpty) {
      return 'El nombre del cliente es obligatorio'; // ⚠️ Error si está vacío
    }

    // 🔍 VALIDACIÓN: Cliente debe tener al menos 2 caracteres
    if (cliente.trim().length < 2) {
      return 'El nombre del cliente debe tener al menos 2 caracteres'; // ⚠️ Error si es muy corto
    }

    return null; // ✅ Todos los campos válidos
  }
}
