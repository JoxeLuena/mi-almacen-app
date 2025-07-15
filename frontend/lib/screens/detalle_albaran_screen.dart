import 'package:flutter/material.dart';          // 🎨 Widgets de Flutter
import '../models/albaran.dart';                  // 📋 Nuestro modelo de datos

class DetalleAlbaranScreen extends StatelessWidget { // 📱 Pantalla de detalles (no cambia, solo muestra)
  final Albaran albaran;                         // 📋 El albarán que vamos a mostrar

  const DetalleAlbaranScreen({                   // 🏗️ Constructor: recibe el albarán a mostrar
    super.key,
    required this.albaran,                       // 📋 Obligatorio pasar el albarán
  });

  @override
  Widget build(BuildContext context) {          // 🎨 FUNCIÓN: Construir la pantalla
    return Scaffold(                             // 📱 Estructura básica de pantalla
      appBar: AppBar(                           // 📊 Barra superior con botón de volver
        title: Text('Albarán ${albaran.numeroAlbaran}'), // 🏷️ Título dinámico con número
        backgroundColor: Colors.blue,            // 🎨 Color azul igual que la pantalla principal
        foregroundColor: Colors.white,           // 🎨 Texto blanco
      ),
      body: Padding(                            // 📏 Añadir márgenes alrededor del contenido
        padding: const EdgeInsets.all(16.0),    // 📏 16 píxeles de margen en todos lados
        child: Column(                          // 📋 Columna vertical con información
          crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear todo a la izquierda
          children: [
            // 🃏 TARJETA: Información principal
            Card(                               // 🃏 Tarjeta con sombra y bordes redondeados
              elevation: 4,                     // 🌫️ Sombra más pronunciada
              child: Padding(                   // 📏 Margen interno de la tarjeta
                padding: const EdgeInsets.all(16.0),
                child: Column(                  // 📋 Columna con datos principales
                  crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
                  children: [
                    // 🏷️ TÍTULO: Número de albarán
                    Text(
                      'Albarán ${albaran.numeroAlbaran}', // 📝 Mostrar número
                      style: const TextStyle(           // 🎨 Estilo del texto
                        fontSize: 24,                    // 📏 Tamaño grande
                        fontWeight: FontWeight.bold,     // 🔤 Texto en negrita
                        color: Colors.blue,              // 🔵 Color azul
                      ),
                    ),
                    const SizedBox(height: 8),          // 📏 Espacio vertical pequeño
                    
                    // 👤 CLIENTE
                    Text(
                      'Cliente: ${albaran.cliente}',    // 👤 Mostrar nombre del cliente
                      style: const TextStyle(           // 🎨 Estilo del texto
                        fontSize: 18,                    // 📏 Tamaño mediano
                        fontWeight: FontWeight.w500,     // 🔤 Semi-negrita
                      ),
                    ),
                    const SizedBox(height: 4),          // 📏 Espacio vertical muy pequeño
                    
                    // 📊 ESTADO con color
                    Row(                                // ➡️ Fila horizontal
                      children: [
                        const Text(                     // 🏷️ Etiqueta fija
                          'Estado: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(                      // 📦 Contenedor para el estado con color
                          padding: const EdgeInsets.symmetric( // 📏 Padding horizontal y vertical
                            horizontal: 8,              // ↔️ 8 píxeles a los lados
                            vertical: 4,                // ↕️ 4 píxeles arriba y abajo
                          ),
                          decoration: BoxDecoration(    // 🎨 Decoración del contenedor
                            color: _getEstadoColor(albaran.estado), // 🎨 Color según el estado
                            borderRadius: BorderRadius.circular(8), // 🔄 Bordes redondeados
                          ),
                          child: Text(                  // 📝 Texto del estado
                            albaran.estado.toUpperCase(), // 🔤 Estado en mayúsculas
                            style: const TextStyle(     // 🎨 Estilo del texto
                              color: Colors.white,      // ⚪ Texto blanco
                              fontWeight: FontWeight.bold, // 🔤 Negrita
                              fontSize: 12,             // 📏 Tamaño pequeño
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),                // 📏 Espacio entre tarjetas
            
            // 🃏 TARJETA: Información adicional
            Card(                                      // 🃏 Segunda tarjeta
              elevation: 4,                           // 🌫️ Misma sombra
              child: Padding(                         // 📏 Margen interno
                padding: const EdgeInsets.all(16.0),
                child: Column(                        // 📋 Columna con más información
                  crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
                  children: [
                    // 📍 DIRECCIÓN DE ENTREGA
                    _buildInfoRow(                    // 📝 Función auxiliar para mostrar información
                      'Dirección de entrega:',        // 🏷️ Etiqueta
                      albaran.direccionEntrega ?? 'No especificada', // 📍 Dirección o texto por defecto
                    ),
                    const SizedBox(height: 8),        // 📏 Espacio vertical
                    
                    // 📅 FECHA DE CREACIÓN
                    _buildInfoRow(
                      'Fecha de creación:',           // 🏷️ Etiqueta
                      _formatearFecha(albaran.fechaCreacion), // 📅 Fecha formateada
                    ),
                    const SizedBox(height: 8),        // 📏 Espacio vertical
                    
                    // 📝 OBSERVACIONES
                    _buildInfoRow(
                      'Observaciones:',               // 🏷️ Etiqueta
                      albaran.observaciones ?? 'Sin observaciones', // 📝 Observaciones o texto por defecto
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),              // 📏 Espacio grande
            
            // 🔘 BOTONES DE ACCIÓN
            Row(                                     // ➡️ Fila horizontal con botones
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 🎯 Distribuir botones uniformemente
              children: [
                // ✏️ BOTÓN: Editar albarán
                ElevatedButton.icon(                 // 🔘 Botón con icono
                  onPressed: () {                   // 👆 Qué hacer cuando lo pulsen
                    // TODO: Implementar edición
                    ScaffoldMessenger.of(context).showSnackBar( // 🔔 Mostrar mensaje temporal
                      const SnackBar(content: Text('Editar albarán - Próximamente')), // 📢 Mensaje
                    );
                  },
                  icon: const Icon(Icons.edit),      // ✏️ Icono de editar
                  label: const Text('Editar'),       // 🏷️ Texto del botón
                  style: ElevatedButton.styleFrom(   // 🎨 Estilo del botón
                    backgroundColor: Colors.orange,  // 🟠 Color naranja
                    foregroundColor: Colors.white,   // ⚪ Texto blanco
                  ),
                ),
                
                // 📦 BOTÓN: Ver productos
                ElevatedButton.icon(                 // 🔘 Botón con icono
                  onPressed: () {                   // 👆 Qué hacer cuando lo pulsen
                    // TODO: Implementar lista de productos
                    ScaffoldMessenger.of(context).showSnackBar( // 🔔 Mostrar mensaje temporal
                      const SnackBar(content: Text('Ver productos - Próximamente')), // 📢 Mensaje
                    );
                  },
                  icon: const Icon(Icons.inventory), // 📦 Icono de inventario
                  label: const Text('Productos'),    // 🏷️ Texto del botón
                  style: ElevatedButton.styleFrom(   // 🎨 Estilo del botón
                    backgroundColor: Colors.green,   // 🟢 Color verde
                    foregroundColor: Colors.white,   // ⚪ Texto blanco
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 FUNCIÓN AUXILIAR: Obtener color según el estado
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {                  // 🔄 Convertir a minúsculas para comparar
      case 'pendiente':
        return Colors.orange;                        // 🟠 Naranja para pendiente
      case 'enviado':
        return Colors.blue;                          // 🔵 Azul para enviado
      case 'entregado':
        return Colors.green;                         // 🟢 Verde para entregado
      default:
        return Colors.grey;                          // ⚫ Gris para estados desconocidos
    }
  }

  // 📝 FUNCIÓN AUXILIAR: Crear fila de información
  Widget _buildInfoRow(String label, String value) {
    return Column(                                   // 📋 Columna vertical
      crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Alinear a la izquierda
      children: [
        Text(                                       // 🏷️ Etiqueta
          label,
          style: const TextStyle(                   // 🎨 Estilo de la etiqueta
            fontWeight: FontWeight.bold,            // 🔤 Negrita
            color: Colors.grey,                     // ⚫ Color gris
            fontSize: 14,                           // 📏 Tamaño pequeño
          ),
        ),
        const SizedBox(height: 2),                  // 📏 Espacio muy pequeño
        Text(                                       // 📝 Valor
          value,
          style: const TextStyle(                   // 🎨 Estilo del valor
            fontSize: 16,                           // 📏 Tamaño normal
          ),
        ),
      ],
    );
  }

  // 📅 FUNCIÓN AUXILIAR: Formatear fecha
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/' + // 📅 Día con 2 dígitos
           '${fecha.month.toString().padLeft(2, '0')}/' + // 📅 Mes con 2 dígitos
           '${fecha.year} ' +                            // 📅 Año
           '${fecha.hour.toString().padLeft(2, '0')}:' + // 🕐 Hora con 2 dígitos
           '${fecha.minute.toString().padLeft(2, '0')}'; // 🕐 Minutos con 2 dígitos
  }
}